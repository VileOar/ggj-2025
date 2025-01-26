class_name PlayerState
extends StackState


# min impulse magnitude when bouncing off of bubbles
const MIN_BUBBLE_BOUNCE = 40
# max impulse magnitude when bouncing off of bubbles
const MAX_BUBBLE_BOUNCE = 16000

# whether the player can change states
var _can_change_state = true


func rigidbody() -> RigidBody2D:
	return fsm().rigidbody()


## Override in child classes
func integrate_forces(_ph_state: PhysicsDirectBodyState2D) -> void:
	pass


func apply_uncentred_impulse(impulse: Vector2):
	rigidbody().apply_impulse(impulse, Vector2(randf_range(-8, 8), randf_range(-8, 8)))


func start_state_cooldown() -> void:
	_can_change_state = false
	await get_tree().create_timer(1).timeout
	_can_change_state = true


func can_change_state() -> bool:
	return _can_change_state


func on_collision(body: Node) -> void:
	pass
