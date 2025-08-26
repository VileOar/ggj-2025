class_name PlayerFSM
extends StackStateMachine


@onready var _rigid_body := get_parent() as Player
@onready var _anim_player_1: AnimatedSprite2D = %Player1AnimatedSprite
@onready var _anim_player_2: AnimatedSprite2D = %Player2AnimatedSprite

var _sound_by_name : Dictionary = {}
var _anim: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	_set_player_animation_sprite()
	push_state("WalkState")

	_sound_by_name["walk"] = %WalkStream
	_sound_by_name["taunt"] = %TauntStream
	_sound_by_name["death"] = %DeathStream
	_sound_by_name["flail"] = %FlailStream
	_sound_by_name["charge"] = %ChargeStream


# Sets the animated sprite to be player 1 (orange) or player 2 (yellow)
func _set_player_animation_sprite():
	if _rigid_body.name == "Player1":
		_anim = _anim_player_1
		_anim_player_2.hide()
	elif _rigid_body.name == "Player2":
		_anim = _anim_player_2
		_anim_player_1.hide()
	else:
		print("Error - Invalid player name, couldn't set animated sprite corretcly")
		_anim = _anim_player_1
		_anim_player_2.hide()


func rigidbody() -> Player:
	return _rigid_body


## Called by the RigidBody's _integrate_forces method
func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	current_state().integrate_forces(ph_state)


func _on_player_scene_body_entered(body: Node) -> void:
	current_state().on_collision(body)


@rpc("any_peer")
func play_anim(anim_name) -> void:
	_anim.play(anim_name)
	
func play_anim_local(anim_name) -> void:
	_anim.play(anim_name)


func play_audio(audio_name:String, start:bool) -> void:
	var audio_node : AudioStreamPlayer2D = _sound_by_name.get(audio_name)
	if audio_node != null:
		if start and !audio_node.is_playing():
			audio_node.play()
		elif audio_node.is_playing():
			audio_node.stop()
