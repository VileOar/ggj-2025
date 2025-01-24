extends RigidBody2D


# current angular position on the stage circle (deg)
var _angle_pos = 0.0

# angular speed to move at (deg/s)
var _angular_speed = 20


func _physics_process(delta: float) -> void:
	var mov_amount = 0
	mov_amount += Input.get_action_strength("mov_right")
	mov_amount -= Input.get_action_strength("mov_left")
	
	_angle_pos += mov_amount * _angular_speed * delta
	
	_update_transform()


# manipulate the rigidbody's actual position so that it corresponds to the desired angle around the edge of the stage
func _update_transform():
	position.x = Global.STAGE_RADIUS * cos(deg_to_rad(_angle_pos))
	position.y = Global.STAGE_RADIUS * (-sin(deg_to_rad(_angle_pos)))
	
	rotation = position.angle() - PI/2
