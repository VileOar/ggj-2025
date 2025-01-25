class_name WalkState
extends PlayerState

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
var _strength_inc_speed = 0.6

## maximum strength after which shoot action is forced
var _max_strength_threshold = 1.2

## strength at which the meter rigidbody is pushed in the opposite direction of player movement
var _meter_overlap_strength = 230


func enter() -> void:
	# setup angle_position
	_setup_angle_position()
	start_state_cooldown()


func _process(delta: float) -> void:
	if _holding_button:
		_strength_percent += delta * _strength_inc_speed
		if _strength_percent >= _max_strength_threshold: # reached full percent and over a little (invisible to user)
			spawn_bubble()


func _physics_process(delta: float) -> void:
	_last_position = rigidbody().position
	
	var mov_amount = 0
	mov_amount -= Input.get_action_strength("mov_right")
	mov_amount += Input.get_action_strength("mov_left")

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


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		_holding_button = true
	if event.is_action_released("shoot"):
		spawn_bubble()


func spawn_bubble():
	#TODO: actually spawn bubble
	_strength_percent = 0.0
	_holding_button = false
