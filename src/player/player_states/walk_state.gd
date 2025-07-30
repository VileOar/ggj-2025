class_name WalkState
extends PlayerState

# the max percentage of the max bubble size that the player can achieve with a charge
const MAX_BUBBLE_SCALE_PERCENT = 0.6

# speed at which to launch the bubbles
const MIN_BUBBLE_LAUNCH_SPEED = 100
const MAX_BUBBLE_LAUNCH_SPEED = 400

## ref to the strength indicator sprite
@onready var _aim_meter: Sprite2D = %AimMeter
## ref to the strength indicator rigidbody
@onready var _meter_rb: RigidBody2D = %MeterRB

var _last_position = null

# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 60

## whether player is still pressing to shoot
var _holding_button = false

## counter for current strength, based on press duration
var _strength_percent = 0.0:
	set(value):
		_strength_percent = value
		_aim_meter.material.set("shader_parameter/percent", _strength_percent)

## strength increment speed while pressing to shoot
var _strength_inc_speed = 0.5

## maximum strength after which shoot action is forced
var _max_strength_threshold = 1.0

## strength at which the meter rigidbody is pushed in the opposite direction of player movement
var _meter_overlap_strength = 230

## used to know when walk state changes
var _was_walking = false

## used to know when taunt state changes
var _is_taunting = false

@onready var mp_player_scene: Player = $"../.."


func _ready() -> void:
	register_authority(mp_player_scene.peer_id)


func register_authority(peer_id : int) -> void:
	if MpGameManager.multiplayer_status == 1 || MpGameManager.multiplayer_status == 2 :
		set_multiplayer_authority(peer_id)
		if multiplayer.is_server():
			print("[Host] Walk State Set authority too: " + str(peer_id))
			
		if !multiplayer.is_server():
			print("[Client] Walk State Set authority too: " + str(peer_id))


func enter() -> void:
	# setup angle_position
	_setup_angle_position()
	start_state_cooldown()
	_meter_rb.show()


func exit() -> void:
	_meter_rb.hide()
	_holding_button = false
	_strength_percent = 0

	_stop_sounds()


func _process(delta: float) -> void:
	if _holding_button:
		# GODOT MULTIPLAYER
		if !_is_current_mp_peer_authority():
			return
			
		_strength_percent += delta * _strength_inc_speed
		if _strength_percent >= _max_strength_threshold: # reached full percent and over a little (invisible to user)
			spawn_bubble()


func _physics_process(delta: float) -> void:
	_last_position = rigidbody().position
	var mov_amount = 0

	if Input.get_action_strength(get_action("taunt")):
		if !_is_taunting and !_holding_button:
			_is_taunting = true
			fsm().play_anim("taunt")
			fsm().play_audio("taunt", true)
	else:
		if _is_taunting:
			_is_taunting = false
			fsm().play_audio("taunt", false)
	
	if !_holding_button and !_is_taunting:
		mov_amount -= Input.get_action_strength(get_action("mov_right"))
		mov_amount += Input.get_action_strength(get_action("mov_left"))
		
		if mov_amount != 0:
			# GODOT MULTIPLAYER
			# Stops from playing animation if not authority
			if !_is_current_mp_peer_authority():
				return
			fsm().play_anim("walk")
			if _was_walking == false:
				fsm().play_audio("walk", true)
			_was_walking = true
		else:
			fsm().play_anim("idle")
			_stop_walking()
	else:
		_stop_walking()
		

	# amplify joint2d/drag effect by adding additional force
	if mov_amount != 0:
		_meter_rb.apply_force(rigidbody().transform.x * _meter_overlap_strength * mov_amount)
	
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
	#if multiplayer.is_server():
		#print("[Host] " + rigidbody().name + " Position = " + str(rigidbody().global_position.x))
		#print("_angle_pos = ", _angle_pos)
	#if !multiplayer.is_server():
		#print("[Client] " + rigidbody().name + " Position = " + str(rigidbody().global_position.x))
	target_pos.x += Global.STAGE_RADIUS * cos(deg_to_rad(_angle_pos))
	target_pos.y += Global.STAGE_RADIUS * (sin(deg_to_rad(_angle_pos)))
	
	var target_rot = _angle_pos - 90
		
	ph_state.transform = Transform2D(deg_to_rad(target_rot), target_pos)

# manipulate angle_position variable to correspond to the current angle to centre
func _setup_angle_position():
	_angle_pos = rad_to_deg(rigidbody().position.angle())
	#print("Angle = ", _angle_pos)


func _stop_walking():
	if _was_walking:
		fsm().play_audio("walk", false)
		_was_walking = false


func _stop_sounds():
	fsm().play_audio("walk", false)
	fsm().play_audio("charge", false)
	fsm().play_audio("taunt", false)


# Change to rigid body state
func _bounce_off(bounce_impulse: Vector2):
	if multiplayer.is_server():
		print("[Host] Bounce Off")
	if !multiplayer.is_server():
		print("[Client] Bounce Off")
	
	replace_state("FloatState") # todo: add delay to raycast
	fsm().play_audio("walk", false)
	await get_tree().physics_frame
	apply_uncentred_impulse(bounce_impulse)
	
	
@rpc("any_peer")
func _bounce_off_in_server(bounce_impulse: Vector2):
	print("[Host to client] Bounce Off In Server")
	replace_state("FloatState") # todo: add delay to raycast
	fsm().play_audio("walk", false)
	await get_tree().physics_frame
	apply_uncentred_impulse(bounce_impulse)

		



func on_collision(body: Node) -> void:
	if multiplayer.is_server():
		print("[Host] mp_id = " + str(get_multiplayer_authority()))
		print("[Host] get_unique_id = " + str(multiplayer.get_unique_id()))
		
	if !multiplayer.is_server():
		print("[Client] mp_id = " + str(get_multiplayer_authority()))
		print("[Client] get_unique_id = " + str(multiplayer.get_unique_id()))
	if can_change_state() and not body is StaticBody2D:
		var vec = body.position - rigidbody().position
		
		if body is Bubble:
			var mag = body.get_mass_percentage() * (MAX_BUBBLE_BOUNCE - MIN_BUBBLE_BOUNCE) + MIN_BUBBLE_BOUNCE
			if is_multiplayer_authority():
				_bounce_off(-vec.normalized() * mag)
			elif multiplayer.is_server():
				#_bounce_off(-vec.normalized() * mag)
				_bounce_off_in_server.rpc(-vec.normalized() * mag)
		elif body is Player:
			var mag = randf_range(MIN_BUBBLE_BOUNCE, MAX_BUBBLE_BOUNCE)
			_bounce_off(-vec.normalized() * mag)
			#_bounce_off_in_server(-vec.normalized() * mag)


func _unhandled_input(event):
	if event.is_action_pressed(get_action("shoot")):
		if !_is_current_mp_peer_authority():
			return
		if !_is_taunting:
			_holding_button = true
			fsm().play_anim("charge")
			fsm().play_audio("charge", true)
	if event.is_action_released(get_action("shoot")):
		if !_is_current_mp_peer_authority():
			return
		if _holding_button:
			spawn_bubble()

# GODOT MULTIPLAYER
func _is_current_mp_peer_authority() -> bool:
	#if multiplayer.is_server():
		#print("[Host] mp_id = " + str(get_multiplayer_authority()))
		#print("[Host] get_unique_id = " + str(multiplayer.get_unique_id()))
	#if !multiplayer.is_server():
		#print("[Client] mp_id = " + str(get_multiplayer_authority()))
		#print("[Client] get_unique_id = " + str(multiplayer.get_unique_id()))
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return false
	else:
		return true

func spawn_bubble():
	#if multiplayer.is_server():
		#print("[Host] Spawns Bubble in MP Stage")
	#if !multiplayer.is_server():
		#print("[Client] Spawns Bubble in MP Stage")
	var launch_speed = MIN_BUBBLE_LAUNCH_SPEED + (MAX_BUBBLE_LAUNCH_SPEED - MIN_BUBBLE_LAUNCH_SPEED) * _strength_percent
	
	var pos = _meter_rb.global_position - rigidbody().get_parent().global_position
	var impulse = -Vector2.from_angle(_meter_rb.global_rotation) * launch_speed
	var bubble_scale_percent = MAX_BUBBLE_SCALE_PERCENT * _strength_percent
	Global.bubble_spawner.spawn_bubble(pos, impulse, bubble_scale_percent)

	fsm().play_audio("charge", false)
	AudioManager.play_audio_queue("shoot")
	
	_strength_percent = 0.0
	_holding_button = false
