class_name StackStateMachine
extends Node
## Custom implementation of a stack based FSM.
##
## The state machine will push and pop states in a LIFO so that data from previous states is kept.[br]
## This is meant to use the State pattern with [StackState] nodes as direct children.[br]
## This node should have NO OTHER children, except [StackState] nodes
## NO OTHER processing should be here other than management of the machine. Any additional
## functionality should be implemented by extending this class.[br]
## NOTE: This class does NOT remove nodes from scene tree to disable them, as they might still need
## to be processed, even if they are not at the top of the stack
# v1.2 (2025-01-20)

## Emitted after a pop operation leaves the machine empty.
signal stack_emptied
## emitted when any state notifies being activated.
signal state_activated(state)
## Emitted when any state notifies being deactivated.
signal state_deactivated(state)

## Path to node whose children are the states to use by this machine. All children of the node must
## be of type StackState. If the path is invalid, uses the direct children of the state machine
## node.
@export var _states_nodepath: NodePath

# The stack of all states pushed down; only contains the string id of the states.
var _state_stack: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	var states_holder = get_node(_states_nodepath)
	if states_holder == null: # if no path was passed (default), use this machine itself, instead
		states_holder = self
	
	for child in states_holder.get_children():
		if child is StackState:
			child._custom_init()
			child.activated.connect(_state_activated)
			child.deactivated.connect(_state_deactivated)
		else:
			push_warning(
				"Node '%s' is not a StackState but is designated as such. \
				It will be ignored by state stack, but you should still remove it." % str(child.get_path())
			)


## Return the state node currently at the top of stack.
func current_state() -> StackState:
	return null if _state_stack.is_empty() else get_node(_state_stack.back())


## Return ordered array of every state in the stack, where the last element is the top of the stack.
func get_state_stack() -> Array[String]:
	return _state_stack.duplicate()


# --------------------------------
# || --- MACHINE OPERATIONS --- ||
# --------------------------------

## Push a new state down the stack, deactivating the previous head and activating the pushed one.
func push_state(state: String):
	# if new state is not allowed, do not perform operation
	if !_can_push_state(state):
		return
	
	var new_head = get_node(state)
	if new_head != null: # if valid state name
		var old_head = current_state()
		if old_head != null:
			old_head._base_deactivate()
		
		_state_stack.push_back(state) # push down the new state identifier
		new_head._base_enter()
	else:
		push_error("State Machine has no child node '%s'. Please add the desired state as a child" % state)


## The head of the state stack, returning to the previous state.[br]
## Optionally pass a target state set, executing multiple pops until that one of those is reached or
## stack is empty.
func pop_state(pop_until: Array[String] = []):
	_pop_state(pop_until)
	
	if _state_stack.is_empty():
		stack_emptied.emit()


# Internal pop state function.[br]
# This function must exist because pop state might need to emit the stack emptied signal; however,
# Replace state function (which also performs the same pop function) should never emit the signal
# (because, if it is replacing, it won't be empty after the operation).
func _pop_state(pop_until: Array[String] = []):
	if _state_stack.is_empty():
		return
		
	# always pop at least once
	while true:
		var node = current_state() # will never be null because of if statement before while
		if node != null:
			_state_stack.pop_back() # pop head
			node._base_exit()
		
		# since there's no do ... while statement, check for break inside while
		if (
				pop_until.is_empty() # if pop_until is empty, only pop once
				or _state_stack.is_empty() # pop until no more states are in stack
				or (_state_stack.back() in pop_until) # pop again until a pop state is found
		):
			# if pop_until was not empty, but stack is, it means no desired state was reached
			# so, they either don't exist or something went wrong
			if pop_until.size() and _state_stack.is_empty():
				push_warning("No state among %s was found. State stack was fully emptied." % str(pop_until))
			
			# one of the end conditions was reached
			break
	
	# if not empty after popping is complete, activate new head
	if !_state_stack.is_empty():
		var node = current_state()
		if node.is_active(): # sanity check
			push_warning("Sanity check failed: A node that was not top of stack was already active.")
		else:
			node._base_activate()


## Shorthand to pop and push in one call.
func replace_state(state: StringName, pop_until: Array[String] = []):
	# if new state is not allowed, do not perform operation
	if !_can_push_state(state):
		return
	
	_pop_state(pop_until) # call the internal pop, so that the empty stack signal is never emitted
	push_state(state)
	
	if _state_stack.is_empty(): # failsafe, in case the push operation fails
		stack_emptied.emit()
		push_warning(
			"State Stack is empty after replace operation. This should not normally happen. \
			New state was likely not pushed properly. Check for errors."
		)


# ---------------------
# || --- PRIVATE --- ||
# ---------------------

# Check if current head can transition to specified new state.
func _can_push_state(state: StringName) -> bool:
	return current_state() == null or current_state().allow_next_state(state)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

# Callback for when a new state is activated.
func _state_activated(state: StringName):
	state_activated.emit(state)


# Callback for when a new state is deactivated.
func _state_deactivated(state: StringName):
	state_deactivated.emit(state)
