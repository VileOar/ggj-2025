class_name PlayerFSM
extends StackStateMachine


@onready var _rigid_body := get_parent() as RigidBody2D


func _ready() -> void:
	super._ready()
	push_state("WalkState")


func rigidbody() -> RigidBody2D:
	return _rigid_body


## Called by the RigidBody's _integrate_forces method
func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	current_state().integrate_forces(ph_state)
