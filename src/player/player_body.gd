class_name Player
extends RigidBody2D

@export var player_index := 0
var peer_id : int

@onready var controller: PlayerFSM = %Controller
#@onready var multiplayer_synchronizer: MultiplayerSynchronizer = %MultiplayerSynchronizer


func _ready() -> void:
	#_multiplayer_synchronizer.set_multiplayer_authority(player_id)
	#set_multiplayer_authority(player_id)
	set_multiplayer_authority(peer_id)
	
#	Connects on body ented to controller
	if not body_entered.is_connected(controller._on_player_scene_body_entered):
		body_entered.connect(controller._on_player_scene_body_entered) 


# GODOT MULTIPLAYER
func _enter_tree() -> void:
	print("Player create in status = " + str(MpGameManager.multiplayer_status))
	#_multiplayer_synchronizer.set_multiplayer_authority(player_id)
	
	if MpGameManager.multiplayer_status == 1 || MpGameManager.multiplayer_status == 2 :
		#set_multiplayer_authority(peer_id)
		print("Set authority to = " + str(peer_id))
		var player_id = name.replace("Player", "")
		print("Name to int = " + player_id)
		player_index = player_id.to_int()



func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	controller.integrate_forces(state)
