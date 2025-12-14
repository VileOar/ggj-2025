class_name LoseState
extends PlayerState

const FIGHT_FADE_DURATION := 2.0
const SPRITE_FADE_DURATION := 4.0

func enter():
	rigidbody().collision_layer = 0
	fsm().play_anim("dead")
	fsm().play_audio("dead", true)

	AudioManager.play_audio(Global.Sounds.FINAL_IMPACT)
	AudioManager.fade_audio(Global.Sounds.FIGHT_MUSIC, FIGHT_FADE_DURATION, Global.AUDIO_OFF_VOLUME)

	var drown_tween = create_tween()
	drown_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	drown_tween.tween_property(fsm().get_anim_sprite(), "modulate", Color("6061a3d5"), SPRITE_FADE_DURATION)

	Signals.screen_shake.emit(1.0)
	Signals.crab_lose.emit(rigidbody().player_index)
