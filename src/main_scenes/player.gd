extends RigidBody2D

## ref to the strength indicator sprite
@onready var _aim_meter: Sprite2D = %AimMeter
## ref to the strength indicator rigidbody
@onready var _meter_rb: RigidBody2D = %MeterRB

# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 40

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
var _meter_overlap_strength = 140


var _acceleration = 0.0
var _velo = 0.0
@export var _friction = -0.3
@export var _overlap_speed = 0.1
@export var _minimizer = 0.01
@export var _max_rot = 1 + PI/2


func _physics_process(delta: float) -> void:
	var mov_amount = 0
	mov_amount += Input.get_action_strength("mov_right")
	mov_amount -= Input.get_action_strength("mov_left")

	# amplify joint2d/drag effect by adding additional force
	if mov_amount != 0:
		_meter_rb.apply_force(transform.x * _meter_overlap_strength * -mov_amount)

	mov_amount = mov_amount * _angular_speed * delta
	_angle_pos += mov_amount
	
	_update_transform()


func _process(delta: float) -> void:
	if _holding_button:
		_strength_percent += delta * _strength_inc_speed
		if _strength_percent >= _max_strength_threshold: # reached full percent and over a little (invisible to user)
			spawn_bubble()


# manipulate the rigidbody's actual position so that it corresponds to the desired angle around the edge of the stage
func _update_transform():
	position.x = Global.STAGE_RADIUS * cos(deg_to_rad(_angle_pos))
	position.y = Global.STAGE_RADIUS * (-sin(deg_to_rad(_angle_pos)))
	
	rotation = position.angle() - PI/2


func _input(event):
	if event.is_action_pressed("shoot"):
		_holding_button = true
	if event.is_action_released("shoot"):
		spawn_bubble()


func spawn_bubble():
	#TODO: actually spawn bubble
	_strength_percent = 0.0
	_holding_button = false


func overlapping_meter(move_force : float):
	_acceleration = 0.0
	_acceleration = -move_force * _minimizer
	if move_force == 0:
		pass

	_acceleration += self._velo * _friction
	_velo += _acceleration

	_aim_meter.rotation += (_velo + _acceleration * _overlap_speed)
	_aim_meter.rotation = clamp(_aim_meter.rotation, -2.4, -0.7)


	