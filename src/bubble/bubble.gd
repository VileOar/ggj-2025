class_name Bubble
extends RigidBody2D

signal big_bubble_collision

const MAX_SCALE_LIMIT = 1.6
const MIN_SCALE_LIMIT = 0.5
const MAX_MASS = 100.0
const MIN_MASS = 1.0


@export var SPEED = 300.0

@export var COLLISION_VELOCITY_THRESHOLD = 60.0
@export var COLLISION_SCALE_PERCENTAGE_THRESHOLD = 0.25
@export var ON_JOIN_SCALE_DIVISION_FACTOR = 3

@onready var _bubble_sprite: Sprite2D = $bubble
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bubble: Bubble = $"."


var _bubble_scale : Vector2 = Vector2(1.0, 1.0)
var _rng = RandomNumberGenerator.new()

# variables to change sizes
var _total_percentage_scale = MAX_SCALE_LIMIT - MIN_SCALE_LIMIT
var _total_percentage_mass = MAX_MASS - MIN_MASS

# scale up lerping 
var time = 0
var _is_bubble_ready_to_scale = false
var new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
var new_mass = 1.0


func _ready() -> void:
	# To detect collisions between objects
	set_contact_monitor(true)
	max_contacts_reported = 5
	
	# applies random spawn direction
	_apply_random_start_direction()
	
	# applies random spawn direction
	_set_random_size()


## TEMP, DELETE
func _apply_random_start_direction() -> void: 
	var x_direction = _rng.randf_range(-1, 1)
	var y_direction = _rng.randf_range(-1, 1)
	apply_torque(x_direction)
	apply_impulse(Vector2(SPEED * x_direction, - SPEED * y_direction))


func _set_random_size() -> void: 
	var percentage = _rng.randf_range(0, 1)
	#print("total_percentage_scale = ", total_percentage_scale, " total_percentage_mass = ", total_percentage_scale, " percentage = ", percentage)
	
	var scale_tmp = MIN_SCALE_LIMIT + (_total_percentage_scale * percentage)
	var mass_tmp = MIN_MASS + (_total_percentage_mass * percentage)
	_bubble_scale = Vector2(scale_tmp, scale_tmp)

	# Apply scale and mass to children
	bubble.mass = mass_tmp
	_bubble_sprite.scale = _bubble_scale
	collision_shape_2d.scale = _bubble_scale


func _update_size(new_body_scale) -> void: 
#	Gets percentage based on the current percentage of the the enemy
	var percentage = ((new_body_scale.mass - MIN_MASS) / _total_percentage_mass)
#	Adds 1/3 of the mass to the current bubble
	percentage = percentage / ON_JOIN_SCALE_DIVISION_FACTOR
	
	new_mass = bubble.mass + (MAX_MASS * percentage)

	new_scale = abs(_bubble_scale) + abs(new_body_scale._bubble_scale / ON_JOIN_SCALE_DIVISION_FACTOR)
	#print("Update Scale Ori: ", bubble_scale, " Add: ", (new_body_scale / 3), "Total:", new_scale)
	
	if new_scale.x >= MAX_SCALE_LIMIT:
		new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
	
	if new_mass >= MAX_MASS:
		new_mass = MAX_MASS
		
	# Apply scale to children
	time = 0
	_is_bubble_ready_to_scale = true
	
	
func _update_scale(new_body_scale) -> void: 
	new_scale = abs(_bubble_scale) + abs(new_body_scale._bubble_scale / ON_JOIN_SCALE_DIVISION_FACTOR)
	#print("Update Scale Ori: ", bubble_scale, " Add: ", (new_body_scale / 3), "Total:", new_scale)
	
	if new_scale.x >= MAX_SCALE_LIMIT:
		new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
		
		
	# Apply scale to children
	time = 0
	_is_bubble_ready_to_scale = true
	

func _physics_process(delta: float) -> void:

# When bubble is ready to scale, applies scale over time
	if _is_bubble_ready_to_scale:
		time += delta * 0.1
		_bubble_sprite.scale = _bubble_sprite.scale.lerp(new_scale, time)
		collision_shape_2d.scale = collision_shape_2d.scale.lerp(new_scale, time)
		lerp(bubble.mass, new_mass, time)
		#print("new mass=", bubble.mass)
		if _bubble_sprite.scale == new_scale:
			_is_bubble_ready_to_scale = false


func _is_slow_collision() -> bool:
#	Detects if FASTER than threshold
	if abs(linear_velocity.x) > COLLISION_VELOCITY_THRESHOLD || abs(linear_velocity.y) > COLLISION_VELOCITY_THRESHOLD:
		return false
	else:
		return true


func _is_scale_difference_small(body) -> bool:
	var scale_difference = abs(_bubble_scale.x - body._bubble_scale.x)
	#print("Myself = ", _bubble_scale.x)
	#print("Other = ", body._bubble_scale.x)
	#print("scale_difference = ", scale_difference)
	
#	Detects if SCALE_DIFFERENCE IS BIGGER than threshold
	if scale_difference > COLLISION_SCALE_PERCENTAGE_THRESHOLD:
		big_bubble_collision.emit()
		return false
	else:
		return true


func _on_body_entered(body: Node2D) -> void:
	if body is Bubble:
		
		if _is_slow_collision():
			return
		
		if _is_scale_difference_small(body):
			return
			
		if _bubble_scale.x >= body._bubble_scale.x:
			## PLAY ANIMATION 
			_update_size(body)
		else:
			print("DELETE BUBBLE")
			## PLAY ANIMATION 
			queue_free()
