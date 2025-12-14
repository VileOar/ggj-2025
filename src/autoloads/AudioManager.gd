extends Node

## Dictionary to store each SoundPlayer nodes by its name
var _sound_player_by_name: Dictionary = {}

## Dictionary to store sound cooldowns based on Global sound enum
var _sound_cooldowns: Dictionary = {}


func _ready():
	_add_to_sound_player_dictionary(Global.Sounds.ACCEPT_UI, $UI/ButtonAccept)
	_add_to_sound_player_dictionary(Global.Sounds.HOVER_UI, $UI/ButtonHover)
	_add_to_sound_player_dictionary(Global.Sounds.CANCEL_UI, $UI/ButtonCancel)

	_add_to_sound_player_dictionary(Global.Sounds.MAIN_MENU_MUSIC, $MainMenu/MainMenuMusic)
	_add_to_sound_player_dictionary(Global.Sounds.MAIN_MENU_AMBIANCE, $MainMenu/MainMenuAmbience)

	_add_to_sound_player_dictionary(Global.Sounds.FIGHT_MUSIC, $Fight/FightMusic)
	_add_to_sound_player_dictionary(Global.Sounds.FIGHT_CLASH, $Fight/FightClash)
	_add_to_sound_player_dictionary(Global.Sounds.FINAL_IMPACT, $Fight/FinalImpact)

	_add_to_sound_player_dictionary(Global.Sounds.END_JINGLE, $EndMenu/EndJingle)
	_add_to_sound_player_dictionary(Global.Sounds.END_MUSIC, $EndMenu/EndMusic)

	_sound_cooldowns[Global.Sounds.BUBBLE_SHOOT] = false
	_sound_cooldowns[Global.Sounds.BUBBLE_BOUNCE] = false
	_sound_cooldowns[Global.Sounds.BUBBLE_POP] = false


func _add_to_sound_player_dictionary(node_name, node):
	_sound_player_by_name[node_name] = node


func play_audio(audio_name, volume = null):
	var audio_node = _sound_player_by_name.get(audio_name)
	if audio_node != null:
		if volume != null:
			audio_node.volume_db = volume

		audio_node.play()


func stop_audio(audio_name):
	var audio_node = _sound_player_by_name.get(audio_name)
	if audio_node != null:
		audio_node.stop()


func play_with_delay(cooldown_to_use, delay: float, shoot_func):
	if !_sound_cooldowns.get(cooldown_to_use):
		_sound_cooldowns[cooldown_to_use] = true
		shoot_func.call()
		await get_tree().create_timer(delay).timeout
		_sound_cooldowns[cooldown_to_use] = false


func fade_audio(audio_name, fade_duration: float, target_volume: float):
	var audio_node = _sound_player_by_name.get(audio_name)

	if audio_node != null:
		var audio_tween = create_tween()
		audio_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		audio_tween.tween_property(audio_node, "volume_db", target_volume, fade_duration)

		await audio_tween.finished
		if audio_node.volume_db <= Global.AUDIO_OFF_VOLUME:
			audio_node.stop()
