class_name Bubble
extends RigidBody2D

signal big_bubble_collision

const MAX_SCALE_LIMIT = 1.65
const MIN_SCALE_LIMIT = 0.5

const SPEED = 300.0

const COLLISION_VELOCITY_THRESHOLD = 60.0
const COLLISION_SCALE_PERCENTAGE_THRESHOLD = 0.25
const ON_JOIN_SCALE_DIVISION_FACTOR = 3

@onready var bubble: Sprite2D = $bubble
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var bubble_scale : Vector2 = Vector2(1.0, 1.0)
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	# To detect collisions between objects
	set_contact_monitor(true)
	max_contacts_reported = 5
	
	# applies random spawn direction
	_apply_random_start_direction()
	
	# applies random spawn direction
	_set_random_scale() 
	
	# apply velocity	
	#velocity = Vector2(SPEED * x_direction, - SPEED * y_direction)


## TEMP, DELETE
func _apply_random_start_direction() -> void: 
	var x_direction = rng.randf_range(-1, 1)
	var y_direction = rng.randf_range(-1, 1)
	apply_torque(x_direction)
	apply_impulse(Vector2(SPEED * x_direction, - SPEED * y_direction))


func _set_random_scale() -> void: 
	var scale_tmp = rng.randf_range(0.5, 1.5)
	bubble_scale = Vector2(scale_tmp, scale_tmp)
	
	# Apply scale to children
	bubble.scale = bubble_scale
	collision_shape_2d.scale = bubble_scale


func _update_scale(new_body_scale: Vector2) -> void: 
	var new_scale: Vector2 = abs(bubble_scale) + abs(new_body_scale / ON_JOIN_SCALE_DIVISION_FACTOR)
	print("Update Scale Ori: ", bubble_scale, " Add: ", (new_body_scale / 3), "Total:", new_scale)
	
	if new_scale.x >= MAX_SCALE_LIMIT:
		new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
		
	# Apply scale to children
	bubble.scale = new_scale 
	collision_shape_2d.scale = new_scale

	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
		
	for collider_index in state.get_contact_count():
		var collider := state.get_contact_collider_object(collider_index)
		var collision_normal := state.get_contact_local_normal(collider_index)
	

#func _change_direction_slighly(collision_info) -> void:
	#var new_bounce_vector = collision_info.get_normal()
	#new_bounce_vector.x += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	#new_bounce_vector.y += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	#velocity = velocity.bounce(new_bounce_vector.normalized())


func _is_slow_collision() -> bool:
#	Detects if FASTER than threshold
	if abs(linear_velocity.x) > COLLISION_VELOCITY_THRESHOLD || abs(linear_velocity.y) > COLLISION_VELOCITY_THRESHOLD:
		return false
	else:
		return true


func _is_scale_difference_small(body) -> bool:
	#var scale_difference = bubble_scale.x - body.scale.x 
	var scale_difference = snappedf(bubble_scale.x, 0.001) - snappedf(body.scale.x , 0.001)
	#snappedf(bubble_scale.x, 0.001)
	#snappedf(body.scale.x , 0.001)
	scale_difference = abs(scale_difference)
	print("Myself = ", bubble_scale.x)
	print("Other = ", body.bubble_scale.x)
	print("Myself = ", snappedf(bubble_scale.x, 0.001))
	print("Other = ", snappedf(body.scale.x , 0.001))
	print("scale_difference = ", scale_difference)
	
#	Detects if SCALE_DIFFERENCE IS BIGGER than threshold
	if scale_difference > COLLISION_SCALE_PERCENTAGE_THRESHOLD:
		big_bubble_collision.emit()
		return false
	else:
		return true


func _on_body_entered(body: Node2D) -> void:
	if body is Bubble:
		#if _is_slow_collision():
			#return
		
		if _is_scale_difference_small(body):
			return
			
		print("scale difference is valid")
		
		if bubble_scale.x >= body.bubble_scale.x:
			print("BIG")
			#_update_scale(body.bubble_scale)
			#body.queue_free()
		#else:
			#print("DELETE")
			#queue_free()

		
			
