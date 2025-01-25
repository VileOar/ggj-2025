class_name WalkState
extends PlayerState


# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 60


func enter() -> void:
	# disable rigidbody physics
	#rigidbody().sleeping = true
	# setup angle_position
	_setup_angle_position()


func _physics_process(delta: float) -> void:
	var mov_amount = 0
	mov_amount -= Input.get_action_strength("mov_right")
	mov_amount += Input.get_action_strength("mov_left")
	
	_angle_pos += mov_amount * _angular_speed * delta


func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	ph_state.linear_velocity = Vector2.ZERO
	ph_state.angular_velocity = 0.0
	
	_update_transform(ph_state)
	


# TODO: remove
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_W:
			_bounce_off()
			await get_tree().physics_frame
			(rigidbody() as RigidBody2D).apply_central_impulse(240 * Vector2.UP)


# manipulate the rigidbody's actual position so that it corresponds to the desired angle around the edge of the stage
func _update_transform(ph_state: PhysicsDirectBodyState2D):
	var target_pos = rigidbody().get_parent().global_position
	target_pos.x += Global.STAGE_RADIUS * cos(deg_to_rad(_angle_pos))
	target_pos.y += Global.STAGE_RADIUS * (sin(deg_to_rad(_angle_pos)))
	
	var target_rot = _angle_pos - 90
	
	ph_state.transform = Transform2D(deg_to_rad(target_rot), target_pos)


# manipulate angle_position variable to correspond to the current angle to centre
func _setup_angle_position():
	_angle_pos = rad_to_deg(rigidbody().position.angle())


# Change to rigid body state
func _bounce_off():
	replace_state("FloatState") # todo: add delay to raycast


func _on_player_scene_body_entered(body: Node) -> void:
	_bounce_off()
