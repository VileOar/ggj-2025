class_name Bubble
extends RigidBody2D

signal big_bubble_collision

@export var BURST: PackedScene
@export var BUBBLE_TRACE: PackedScene

const MAX_SCALE_LIMIT = 1.6
const MIN_SCALE_LIMIT = 0.2
const MAX_MASS = 20.0
const MIN_MASS = 1.0

const MAX_HEALTH = 10
const MIN_HEALTH = 2

# percentage of size; under this value, bubbles will have lifespan
const LIFESPAN_PERCENT_THRESH = 0.2
const LIFESPAN_TIME = 5


@export var SPEED = 300.0

@export var COLLISION_VELOCITY_THRESHOLD = 60.0
@export var COLLISION_SCALE_PERCENTAGE_THRESHOLD = 0.25
@export var ON_JOIN_SCALE_DIVISION_FACTOR = 3
@export var BUBBLE_IS_DANGEROUS_PERCENTAGE = 0.4

@onready var _bubble_sprite: Node2D = $bubble
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bubble: Bubble = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $bubble/AnimProxy/AnimatedSprite2D
@onready var lifespan: Timer = $Lifespan
@onready var trace_timer: Timer = $TraceTimer


var _bubble_scale : Vector2 = Vector2(1.0, 1.0)
@warning_ignore("unused_private_class_variable")
var _rng = RandomNumberGenerator.new()

# variables to change sizes
var _total_percentage_scale = MAX_SCALE_LIMIT - MIN_SCALE_LIMIT
var _total_percentage_mass = MAX_MASS - MIN_MASS

# scale up lerping 
var time = 0
var _is_bubble_ready_to_scale = false
var new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
var new_mass = 1.0

# num of hits before bursting
var health = 1
var scale_percent


func _ready() -> void:
	# To detect collisions between objects
	set_contact_monitor(true)
	max_contacts_reported = 5


func setup_bubble(impulse: Vector2, _scale_percent: float) -> void:
	apply_impulse(impulse)
	scale_percent = _scale_percent
	
	var scale_tmp = MIN_SCALE_LIMIT + (_total_percentage_scale * _scale_percent)
	var mass_tmp = MIN_MASS + (_total_percentage_mass * _scale_percent)
	_bubble_scale = Vector2(scale_tmp, scale_tmp)
	
	# Apply scale and mass to children
	bubble.mass = mass_tmp
	_bubble_sprite.scale = _bubble_scale
	collision_shape_2d.scale = _bubble_scale
	
	health = MIN_HEALTH + (MAX_HEALTH - MIN_HEALTH) * _scale_percent
	
	if is_bubble_dangerous():
		print("activate")
		animated_sprite_2d.activate_vfx_shine()
		trace_timer.start()
	
	if _scale_percent < LIFESPAN_PERCENT_THRESH:
		lifespan.start(LIFESPAN_TIME)


func _create_trace_effect() -> void:
	var bubble_trace = BUBBLE_TRACE.instantiate()
	bubble_trace.position = position
	bubble_trace.scale = _bubble_sprite.scale
	get_parent().add_child(bubble_trace)


func get_mass_percentage() -> float:
	return bubble.mass / MAX_MASS


func _update_size(new_body_scale) -> void: 
#	Gets percentage based on the current percentage of the the enemy
	var percentage = (max(0, new_body_scale.mass - MIN_MASS) / _total_percentage_mass)
#	Adds 1/3 of the mass to the current bubble
	percentage = percentage / ON_JOIN_SCALE_DIVISION_FACTOR
	
	new_mass = bubble.mass + (MAX_MASS * percentage)

	new_scale = abs(_bubble_scale) + abs(new_body_scale._bubble_scale / ON_JOIN_SCALE_DIVISION_FACTOR)
	#print("Update Scale Ori: ", bubble_scale, " Add: ", (new_body_scale / 3), "Total:", new_scale)
	
	if new_scale.x >= MAX_SCALE_LIMIT:
		new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
	
	if new_mass >= MAX_MASS:
		new_mass = MAX_MASS
	
	health = MIN_HEALTH + (MAX_HEALTH - MIN_HEALTH) * percentage
	
	if percentage < LIFESPAN_PERCENT_THRESH:
		lifespan.start(LIFESPAN_TIME)
	
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
	
	if position.length() >= Global.STAGE_RADIUS + 48:
		queue_free()


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
	lifespan.start(LIFESPAN_TIME)
	animation_player.play("bounce")
	if body is Bubble:
		
		if _is_scale_difference_small(body):
			return
		
		if _bubble_scale.x >= body._bubble_scale.x:
			## PLAY ANIMATION 
			_update_size(body)
		else:
			## PLAY ANIMATION 
			queue_free()
	
	health -= 1
	
	# bursting
	if body is Player or health <= 0:
		## PLAY ANIMATION 
		animation_player.stop()
		var burst = BURST.instantiate()
		burst.position = position
		burst.scale = _bubble_sprite.scale
		get_parent().add_child(burst)
		queue_free()


func _on_lifespan_timeout() -> void:
	queue_free()


func is_bubble_dangerous() -> bool:
	#if scale_percent > BUBBLE_IS_DANGEROUS_PERCENTAGE and !_is_slow_collision():
	if scale_percent > BUBBLE_IS_DANGEROUS_PERCENTAGE:
		return true
	else:
		return false


func _on_timer_timeout() -> void:
	_create_trace_effect()
