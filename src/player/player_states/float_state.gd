class_name FloatState
extends PlayerState


const SNAP_SPEED_THRESH = 20
const BORDER_DISTANCE_THRES = 4


func enter() -> void:
	start_state_cooldown()


func _physics_process(delta: float) -> void:
	# whether moving at low speed
	var low_speed = rigidbody().linear_velocity.length() <= SNAP_SPEED_THRESH
	# whether position is close to stage border
	var close_to_ground = Global.STAGE_RADIUS - rigidbody().position.length() <= BORDER_DISTANCE_THRES
	
	print_debug(rigidbody().linear_velocity.length())
	
	if can_change_state() and low_speed and close_to_ground:
		replace_state("WalkState")


func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	pass
	#var target_pos = rigidbody().get_parent().global_position
	#var src_angle = ph_state.transform.get_rotation()
	#var dst_angle = ph_state.transform.origin.angle_to_point(target_pos) + deg_to_rad(90)
	#
	#print_debug("%.0f v %.0f" % [rad_to_deg(dst_angle), rad_to_deg(src_angle)])
	#
	#var angle_delta = dst_angle - src_angle
	#
	#print_debug(rad_to_deg(_rotation_speed))
	#var angle_shift = min(deg_to_rad(_rotation_speed) * sign(angle_delta), angle_delta)
	#
	#var xform = Transform2D(src_angle + angle_shift, ph_state.transform.origin)
	#ph_state.transform = xform
	
	#fsm().rigidbody().apply_torque_impulse(-angle_delta)
