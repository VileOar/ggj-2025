class_name Player
extends RigidBody2D

@export var player_index := 0

@onready var controller: PlayerFSM = %Controller

func _ready() -> void:
#	Connects on body ented to controller
	body_entered.connect(controller._on_player_scene_body_entered) 


# GODOT MULTIPLAYER
func _enter_tree() -> void:
	#print(MpGameManager.mp_players)
	if MpGameManager.multiplayer_status == 1:
		set_multiplayer_authority(name.to_int())
		player_index = name.to_int()
	if MpGameManager.multiplayer_status == 2:
		set_multiplayer_authority(name.to_int())
#		player to join in is always the second one
		player_index = 0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	controller.integrate_forces(state)
