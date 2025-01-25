class_name PlayerState
extends StackState


# whether the player can change states
var _can_change_state = true


func rigidbody() -> RigidBody2D:
	return fsm().rigidbody()


## Override in child classes
func integrate_forces(_ph_state: PhysicsDirectBodyState2D) -> void:
	pass


func start_state_cooldown() -> void:
	_can_change_state = false
	await get_tree().create_timer(1).timeout
	_can_change_state = true


func can_change_state() -> bool:
	return _can_change_state
