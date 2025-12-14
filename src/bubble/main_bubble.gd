class_name Bubble
extends RigidBody2D

const MAX_SCALE_LIMIT = 1.6
const MIN_SCALE_LIMIT = 0.2
const MAX_MASS = 20.0
const MIN_MASS = 1.0
const MAX_HEALTH = 10
const MIN_HEALTH = 2

## Percentage of size. Under this value, bubbles will start with lifespan.
const LIFESPAN_PERCENT_THRESH = 0.2
## All bubbles get this value of lifespan after each bounce.
const LIFESPAN_TIME = 5
## Velocity higher than this is considered a fast collision.
const COLLISION_VELOCITY_THRESHOLD = 100.0
## Scale difference lower than this is considered a small collision.
const COLLISION_SCALE_PERCENTAGE_THRESHOLD = 0.25
## On update size, the mass from the other bubble that is actually used depends on division by this value.
const ON_JOIN_SCALE_DIVISION_FACTOR = 3

const BOUNCE_SOUND_DELAY = 0.3
const STRONG_BUBBLE_SCRN_SHAKE = 0.7

@export var burst_scene: PackedScene
@export var trace_scene: PackedScene

## Num of hits before bursting.
var _health = 1
var _can_trace = false

# Also functioning as consts
var _total_percentage_scale = MAX_SCALE_LIMIT - MIN_SCALE_LIMIT
var _total_percentage_mass = MAX_MASS - MIN_MASS

var _initial_scale_percent
var _bubble_scale: Vector2 = Vector2(1.0, 1.0)
# Scaling over time vars
var _is_bubble_ready_to_scale = false
var _new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)
var _new_mass = 1.0
var _lerp_time_cache = 0

@onready var _self_rigidbody: Bubble = $"."
@onready var _bubble_sprite: Node2D = $SpriteHolder
@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _bounce_stream: AudioStreamPlayer2D = %BounceStream
@onready var _thwop_stream: AudioStreamPlayer2D = %ThwopStream
@onready var _lifespan_timer: Timer = %LifespanTimer


func _ready() -> void:
	# To detect collisions between objects
	set_contact_monitor(true)
	max_contacts_reported = 5


func setup_bubble(impulse: Vector2, in_scale_percent: float) -> void:
	apply_impulse(impulse)
	_initial_scale_percent = in_scale_percent

	var scale_tmp = MIN_SCALE_LIMIT + (_total_percentage_scale * _initial_scale_percent)
	var mass_tmp = MIN_MASS + (_total_percentage_mass * _initial_scale_percent)
	_bubble_scale = Vector2(scale_tmp, scale_tmp)

	# Apply scale and mass to children
	_self_rigidbody.mass = mass_tmp
	_bubble_sprite.scale = _bubble_scale
	_collision_shape_2d.scale = _bubble_scale

	_health = MIN_HEALTH + (MAX_HEALTH - MIN_HEALTH) * _initial_scale_percent

	if _initial_scale_percent > Global.BUBBLE_IS_DANGEROUS_PERCENTAGE:
		Signals.screen_shake.emit(STRONG_BUBBLE_SCRN_SHAKE)

	if _initial_scale_percent < LIFESPAN_PERCENT_THRESH:
		_lifespan_timer.start(LIFESPAN_TIME)


func _update_size(new_body_scale) -> void:
	# Gets percentage based on the current percentage of the the enemy
	var percentage = max(0, new_body_scale.mass - MIN_MASS) / _total_percentage_mass

	# Final percentage and mass calcs
	percentage = percentage / ON_JOIN_SCALE_DIVISION_FACTOR
	_new_mass = _self_rigidbody.mass + (MAX_MASS * percentage)

	# Same but for scale
	_new_scale = abs(_bubble_scale) + abs(new_body_scale._bubble_scale / ON_JOIN_SCALE_DIVISION_FACTOR)

	if _new_scale.x >= MAX_SCALE_LIMIT:
		_new_scale = Vector2(MAX_SCALE_LIMIT, MAX_SCALE_LIMIT)

	if _new_mass >= MAX_MASS:
		_new_mass = MAX_MASS

	# Health calc, resetting it from posssible previous decrements
	_health = MIN_HEALTH + (MAX_HEALTH - MIN_HEALTH) * percentage

	if percentage < LIFESPAN_PERCENT_THRESH:
		_lifespan_timer.start(LIFESPAN_TIME)

	_lerp_time_cache = 0
	_is_bubble_ready_to_scale = true


func _physics_process(delta: float) -> void:
	# When bubble is ready to scale, applies scale over time
	if _is_bubble_ready_to_scale:
		_lerp_time_cache += delta * 0.1

		# Scale sprite, collider and mass
		_bubble_sprite.scale = _bubble_sprite.scale.lerp(_new_scale, _lerp_time_cache)
		_collision_shape_2d.scale = _collision_shape_2d.scale.lerp(_new_scale, _lerp_time_cache)
		lerp(_self_rigidbody.mass, _new_mass, _lerp_time_cache)

		if _bubble_sprite.scale == _new_scale:
			_is_bubble_ready_to_scale = false

	# Safety check
	if position.length() >= Global.STAGE_RADIUS + 48:
		queue_free()

	_can_trace = is_bubble_dangerous()


func _on_body_entered(body: Node2D) -> void:
	_lifespan_timer.start(LIFESPAN_TIME)
	_animation_player.play("bounce")

	var has_thwoped = false

	if body is Bubble:
		if _is_scale_difference_small(body):
			var lambda = func(): _bounce_stream.play()
			AudioManager.play_with_delay(Global.Sounds.BUBBLE_BOUNCE, BOUNCE_SOUND_DELAY, lambda)
			return

		# Bigger bubble updates size, while smaller gets destroyed
		if _bubble_scale.x >= body._bubble_scale.x:
			_update_size(body)
			_thwop_stream.play()
			has_thwoped = true
		else:
			queue_free()

	_health -= 1

	if body is Player or _health <= 0:
		_burst_bubble()  # This does queue_free

	if !has_thwoped:
		_bounce_stream.play()


# Used by crab to calc stuff on collision
func get_mass_percentage() -> float:
	return _self_rigidbody.mass / MAX_MASS


func is_bubble_dangerous() -> bool:
	return _initial_scale_percent > Global.BUBBLE_IS_DANGEROUS_PERCENTAGE and _is_fast_collision()


func _is_fast_collision() -> bool:
	return abs(linear_velocity.length()) > COLLISION_VELOCITY_THRESHOLD


func _is_scale_difference_small(body) -> bool:
	var scale_difference = abs(_bubble_scale.x - body._bubble_scale.x)
	return !(scale_difference > COLLISION_SCALE_PERCENTAGE_THRESHOLD)


func _burst_bubble() -> void:
	_animation_player.stop()
	var burst_scene_ref = burst_scene.instantiate()
	burst_scene_ref.position = position
	burst_scene_ref.scale = _bubble_sprite.scale
	get_parent().add_child(burst_scene_ref)
	queue_free()


func _create_trace_effect() -> void:
	var bubble_trace = trace_scene.instantiate()
	bubble_trace.position = position
	bubble_trace.scale = _bubble_sprite.scale * 0.5
	get_parent().add_child(bubble_trace)


func _on_lifespan_timer_timeout() -> void:
	_burst_bubble()


func _on_trace_timer_timeout() -> void:
	if _can_trace:
		_create_trace_effect()
