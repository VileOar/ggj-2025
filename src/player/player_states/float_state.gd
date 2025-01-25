class_name FloatState
extends StackState


func enter() -> void:
	# enable rigidbody physics
	fsm().rigidbody().freeze = false


func _physics_process(delta: float) -> void:
	var src_angle = fsm().rigidbody().rotation - PI/2 # up angle of the player
	var dst_angle = (-fsm().rigidbody().position).angle()
	
	var angle_delta = dst_angle - src_angle
	
	fsm().rigidbody().apply_torque_impulse(-angle_delta)
