class_name WalkState
extends PlayerState


var _last_position = null

# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 60


func enter() -> void:
	# setup angle_position
	_setup_angle_position()
	start_state_cooldown()


func _physics_process(delta: float) -> void:
	_last_position = rigidbody().position
	
	var mov_amount = 0
	mov_amount -= Input.get_action_strength("mov_right")
	mov_amount += Input.get_action_strength("mov_left")
	
	_angle_pos += mov_amount * _angular_speed * delta


func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	if ph_state.get_contact_count():
		return
	ph_state.linear_velocity = Vector2.ZERO
	ph_state.angular_velocity = 0.0
	
	_update_transform(ph_state)


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
func _bounce_off(bounce_impulse: Vector2):
	replace_state("FloatState") # todo: add delay to raycast
	await get_tree().physics_frame
	rigidbody().apply_central_impulse(bounce_impulse)


func _on_player_scene_body_entered(body: Node) -> void:
	if can_change_state() and not body is StaticBody2D:
		var vec = rigidbody().transform.x
		if _last_position != null:
			vec = rigidbody().position - _last_position
		_bounce_off(vec * (-100))
