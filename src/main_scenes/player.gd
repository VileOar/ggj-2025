extends RigidBody2D

## ref to the strength indicator
@onready var _aim_meter: Sprite2D = %AimMeter

# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 20

## whether player is still pressing to shoot
var _holding_button = false

## counter for current strength, based on press duration
var _strength_percent = 0.0:
	set(value):
		_strength_percent = value
		_aim_meter.material.set("shader_parameter/percent", _strength_percent)

## strength increment speed while pressing
var _strength_inc_speed = 0.6


func _physics_process(delta: float) -> void:
	var mov_amount = 0
	mov_amount += Input.get_action_strength("mov_right")
	mov_amount -= Input.get_action_strength("mov_left")
	
	_angle_pos += mov_amount * _angular_speed * delta
	
	_update_transform()


func _process(delta: float) -> void:
	if _holding_button:
		_strength_percent += delta * _strength_inc_speed
		if _strength_percent >= 1.2: # reached full percent and over a little (invisible to user)
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
