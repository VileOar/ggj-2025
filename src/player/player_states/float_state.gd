class_name FloatState
extends PlayerState


const SNAP_SPEED_THRESH = 20
const BORDER_DISTANCE_THRES = 4
const MAX_FLOAT_SPEED = 240

const BUBBLE_COOLDOWN = 0.03


var _can_bubble = true


func enter() -> void:
	start_state_cooldown()
	fsm().play_anim("idle")
	fsm().play_audio("flail", true)


func exit() -> void:
	fsm().play_audio("flail", false)


func _physics_process(_delta: float) -> void:
	# whether moving at low speed
	var low_speed = rigidbody().linear_velocity.length() <= SNAP_SPEED_THRESH
	# whether position is close to stage border
	var close_to_ground = Global.STAGE_RADIUS - rigidbody().position.length() <= BORDER_DISTANCE_THRES
	
	if can_change_state() and low_speed and close_to_ground:
		replace_state("WalkState")
	
	# panic stray attack
	if Input.get_action_strength(get_action("shoot")) and _can_bubble:
		spawn_bubble()
		_can_bubble = false
		await get_tree().create_timer(BUBBLE_COOLDOWN).timeout
		_can_bubble = true


func on_collision(body: Node) -> void:
	if not body is StaticBody2D:
		var vec = body.position - rigidbody().position
		
		if body is Bubble:
			if body.is_bubble_dangerous():
				replace_state("LoseState")
			else:
				var mag = body.get_mass_percentage() * (MAX_BUBBLE_BOUNCE - MIN_BUBBLE_BOUNCE) + MIN_BUBBLE_BOUNCE
				apply_uncentred_impulse(-vec.normalized() * mag)


func spawn_bubble():
	var pos = rigidbody().position + rigidbody().transform.y * 48
	var impulse = Vector2.from_angle(rigidbody().global_rotation) * 100
	var bubble_scale_percent = 0
	Global.bubble_spawner.spawn_bubble(pos, impulse, bubble_scale_percent)
	AudioManager.play_shoot_delay(0.07)
