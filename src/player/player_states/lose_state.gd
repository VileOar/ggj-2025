class_name LoseState
extends PlayerState


func enter():
	rigidbody().collision_layer = 0
	fsm().play_anim("dead")
	fsm().play_audio("dead", true)

	var _drown_tween = create_tween()
	_drown_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_drown_tween.tween_property(fsm().get_anim_sprite(), "modulate", Color("6061a3d5"), 2)

	Signals.crab_lose.emit(rigidbody().player_index)
