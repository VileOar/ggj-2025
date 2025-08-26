class_name LoseState
extends PlayerState


func enter():
	rigidbody().collision_layer = 0
	if is_multiplayer_authority():
		fsm().play_anim.rpc("dead")
		fsm().play_anim_local("dead")
	fsm().play_audio("dead", true)
	Signals.crab_lose.emit(rigidbody().player_index)
