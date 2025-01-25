class_name PlayerState
extends StackState


func rigidbody() -> RigidBody2D:
	return fsm().rigidbody()


## Override in child classes
func integrate_forces(_ph_state: PhysicsDirectBodyState2D) -> void:
	pass
