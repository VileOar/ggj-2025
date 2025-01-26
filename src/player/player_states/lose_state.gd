class_name LoseState
extends PlayerState


func enter():
	rigidbody().collision_layer = 0
	fsm().play_anim("dead")
