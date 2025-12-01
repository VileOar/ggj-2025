extends Node2D

@export var player_index := 0
@export var _current_animation: String
@export var _emitter_left_state := false
@export var _emitter_right_state := false

@onready var _anim_player_1: AnimatedSprite2D = %Player1AnimatedSprite
@onready var _anim_player_2: AnimatedSprite2D = %Player2AnimatedSprite
@onready var _emitter_left: GPUParticles2D = %SandEmitterLeft
@onready var _emitter_right: GPUParticles2D = %SandEmitterRight
@onready var _col_shape: CollisionShape2D = %ClickableCollisionShape2D

var _current_anim_player: AnimatedSprite2D
var _cached_animation: String
var _cached_state_left := false
var _cached_state_right := false

var _animation_player: AnimationPlayer
var _is_taunted := false
var _taunted_cooldown := 1.0


func _ready():
	if player_index == 0:
		_current_anim_player = _anim_player_1
		_anim_player_2.visible = false
	else:
		_current_anim_player = _anim_player_2
		_anim_player_1.visible = false

	_cached_animation = _current_animation
	_current_anim_player.play(_current_animation)

	for child in get_children():
		if child is AnimationPlayer:
			_animation_player = child


func _process(_delta):
	if _cached_animation != _current_animation:
		_cached_animation = _current_animation
		_current_anim_player.play(_current_animation)

	if _cached_state_left != _emitter_left_state:
		_cached_state_left = _emitter_left_state
		_emitter_left.emitting = _emitter_left_state

	if _cached_state_right != _emitter_right_state:
		_cached_state_right = _emitter_right_state
		_emitter_right.emitting = _emitter_right_state


func _input(e):
	if e is InputEventMouseButton:
		if e.button_index == MouseButton.MOUSE_BUTTON_LEFT and e.pressed:
			if _col_shape.shape.get_rect().has_point(to_local(e.position)):
				if _animation_player:
					_handle_click()


func _handle_click():
	if _is_taunted == false:
		_is_taunted = true
		_animation_player.pause()
		_current_anim_player.play("taunt")
		_emitter_left.emitting = false
		_emitter_right.emitting = false
		await get_tree().create_timer(_taunted_cooldown).timeout

		_animation_player.play()
		_current_anim_player.play(_current_animation)
		_emitter_left.emitting = _emitter_left_state
		_emitter_right.emitting = _emitter_right_state
		_is_taunted = false
