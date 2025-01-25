extends RigidBody2D
class_name Bubble

const SPEED = 300.0
const SPEED_STOP_THRESHOLD = 5

const DRAG_RESISTANCE = 0.9999
const ON_COLLISION_DIRECTION_VARIATION = 0.25

const COLLISION_VELOCITY_THRESHOLD = 60.0
const COLLISION_SCALE_PERCENTAGE_THRESHOLD = 0.25

@onready var bubble: Sprite2D = $bubble
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var bubble_scale : Vector2 = Vector2(1.0, 1.0)


var velocity
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
	print("scale applied: ", bubble_scale)


func _physics_process(delta: float) -> void:
	#var collision_info = move_and_collide(velocity * delta)
	#_apply_drag()
	#
	## ON collision detection, changes direction with slight variable 
	#if collision_info:
		#_change_direction_slighly(collision_info)
		#_on_collision_slow_down()
	pass


func _on_collision_slow_down() -> void:
	#print("slow down")
	velocity.x *= 0.99
	velocity.y *= 0.99
	
	#
#func _apply_drag() -> void:
##	stop speed after threshold
	#if abs(velocity.x) < SPEED_STOP_THRESHOLD && abs(velocity.y) < SPEED_STOP_THRESHOLD:
		#velocity.x = 0
		#velocity.y = 0
	#else:
##		apply drag normally
		#velocity.x *= DRAG_RESISTANCE
		#velocity.y *= DRAG_RESISTANCE
		##print(velocity.x)
		##print(velocity.y)
		#pass
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
		
	for collider_index in state.get_contact_count():
		var collider := state.get_contact_collider_object(collider_index)
		var collision_normal := state.get_contact_local_normal(collider_index)
	

func _change_direction_slighly(collision_info) -> void:
	var new_bounce_vector = collision_info.get_normal()
	new_bounce_vector.x += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	new_bounce_vector.y += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	velocity = velocity.bounce(new_bounce_vector.normalized())


#	TODO work
func _on_body_entered(body: Node2D) -> void:
	if body is Bubble:
		print("bubble collision")
		
		if abs(linear_velocity.x) > COLLISION_VELOCITY_THRESHOLD || abs(linear_velocity.y) > COLLISION_VELOCITY_THRESHOLD:
			print("Fast collision")
		else:
			print("slow collision")
			
		var scale_difference = abs(bubble_scale.x - body.scale.x) 
		print("scale difference = ", scale_difference)
		if scale_difference > COLLISION_SCALE_PERCENTAGE_THRESHOLD:
			print("Scale is bigger than threshold")
		else:
			print("Scale is smaller than threshold")
			
			
	#print(body.name)
