class_name WalkState
extends StackState


# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 60


func enter() -> void:
	# disable rigidbody physics
	fsm().rigidbody().freeze = true
	# setup angle_position
	_setup_angle_position()


func _physics_process(delta: float) -> void:
	var mov_amount = 0
	mov_amount += Input.get_action_strength("mov_right")
	mov_amount -= Input.get_action_strength("mov_left")
	
	_angle_pos += mov_amount * _angular_speed * delta
	
	_update_transform()


# TODO: remove
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_W:
			_bounce_off(240 * Vector2.RIGHT)


# manipulate the rigidbody's actual position so that it corresponds to the desired angle around the edge of the stage
func _update_transform():
	fsm().rigidbody().position.x = Global.STAGE_RADIUS * cos(deg_to_rad(_angle_pos))
	fsm().rigidbody().position.y = Global.STAGE_RADIUS * (-sin(deg_to_rad(_angle_pos)))
	
	fsm().rigidbody().rotation = fsm().rigidbody().position.angle() - PI/2


# manipulate angle_position variable to correspond to the current angle to centre
func _setup_angle_position():
	_angle_pos = rad_to_deg(fsm().rigidbody().position.angle())


# Change to rigid body state and apply some impulse
func _bounce_off(impulse_vector: Vector2):
	replace_state("FloatState") # todo: add delay to raycast
	await get_tree().physics_frame
	(fsm().rigidbody() as RigidBody2D).apply_central_impulse(impulse_vector)
