class_name PlayerFSM
extends StackStateMachine

@onready var _rigid_body := get_parent() as Player
@onready var _anim_sprite_1: AnimatedSprite2D = %Player1AnimatedSprite
@onready var _anim_sprite_2: AnimatedSprite2D = %Player2AnimatedSprite

var _sound_by_name: Dictionary = {}
var _current_anim_sprite: AnimatedSprite2D


func _ready() -> void:
	super._ready()

	_sound_by_name["walk"] = %WalkStream
	_sound_by_name["taunt"] = %TauntStream
	_sound_by_name["death"] = %DeathStream
	_sound_by_name["flail"] = %FlailStream
	_sound_by_name["charge"] = %ChargeStream
	_sound_by_name["shoot"] = %ShootStream
	_sound_by_name["shoot_big"] = %ShootBigStream

	_set_player_animation_sprite()
	push_state("WalkState")


## Sets the animated sprite to be player 1 (orange) or player 2 (yellow)
func _set_player_animation_sprite():
	if _rigid_body.player_index == 1:
		_current_anim_sprite = _anim_sprite_1
		_anim_sprite_2.hide()
		_sound_by_name.get("taunt").pitch_scale = 0.9
	elif _rigid_body.player_index == 2:
		_current_anim_sprite = _anim_sprite_2
		_anim_sprite_1.hide()
		_sound_by_name.get("taunt").pitch_scale = 1.1
	else:
		print("Error - Invalid player index, couldn't set animated sprite corretcly")
		_current_anim_sprite = _anim_sprite_1
		_anim_sprite_2.hide()


func rigidbody() -> Player:
	return _rigid_body


func get_anim_sprite() -> AnimatedSprite2D:
	return _current_anim_sprite


## Called by the RigidBody's _integrate_forces method
func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	current_state().integrate_forces(ph_state)


func _on_player_scene_body_entered(body: Node) -> void:
	current_state().on_collision(body)


func play_anim(anim_name) -> void:
	_current_anim_sprite.play(anim_name)


func play_audio(audio_name: String, start: bool) -> void:
	var audio_node: AudioStreamPlayer2D = _sound_by_name.get(audio_name)
	if audio_node != null:
		if start and !audio_node.is_playing():
			audio_node.play()
		elif audio_node.is_playing():
			audio_node.stop()


## This version of audio play does not care if the audio is already playing.
## Good for rapid fire sounds.
func play_audio_one_shot(audio_name: String) -> void:
	var audio_node: AudioStreamPlayer2D = _sound_by_name.get(audio_name)
	if audio_node != null:
		audio_node.play()
