class_name FloatState
extends PlayerState


const SNAP_SPEED_THRESH = 20
const BORDER_DISTANCE_THRES = 4
const MAX_FLOAT_SPEED = 360


func enter() -> void:
	start_state_cooldown()


func _physics_process(delta: float) -> void:
	# whether moving at low speed
	var low_speed = rigidbody().linear_velocity.length() <= SNAP_SPEED_THRESH
	# whether position is close to stage border
	var close_to_ground = Global.STAGE_RADIUS - rigidbody().position.length() <= BORDER_DISTANCE_THRES
	
	if can_change_state() and low_speed and close_to_ground:
		replace_state("WalkState")


func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	var mag = ph_state.linear_velocity.length()
	mag = min(mag, MAX_FLOAT_SPEED)
	ph_state.linear_velocity = ph_state.linear_velocity.normalized() * mag
