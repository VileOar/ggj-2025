class_name LoseState
extends PlayerState


func enter():
	rigidbody().collision_layer = 0
	fsm().play_anim("dead")
	fsm().play_audio("dead", true)
	Signals.crab_lose.emit(rigidbody().player_index)
