class_name FloatState
extends PlayerState


const SNAP_SPEED_THRESH = 20
const BORDER_DISTANCE_THRES = 4
const MAX_FLOAT_SPEED = 240


func enter() -> void:
	start_state_cooldown()
	fsm().play_anim("idle")


func _physics_process(_delta: float) -> void:
	# whether moving at low speed
	var low_speed = rigidbody().linear_velocity.length() <= SNAP_SPEED_THRESH
	# whether position is close to stage border
	var close_to_ground = Global.STAGE_RADIUS - rigidbody().position.length() <= BORDER_DISTANCE_THRES
	
	if can_change_state() and low_speed and close_to_ground:
		replace_state("WalkState")


func on_collision(body: Node) -> void:
	if not body is StaticBody2D:
		var vec = body.position - rigidbody().position
		
		if body is Bubble:
			var mag = body.get_mass_percentage() * (MAX_BUBBLE_BOUNCE - MIN_BUBBLE_BOUNCE) + MIN_BUBBLE_BOUNCE
			apply_uncentred_impulse(-vec.normalized() * mag)
