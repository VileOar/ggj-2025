class_name Player
extends RigidBody2D

@export var player_index := 0
var peer_id : int
var _is_first_disconnect_message := true

@onready var controller: PlayerFSM = %Controller

func _ready() -> void:
	# Connects body entered signal to detech a collision and make the crab float
	if not body_entered.is_connected(controller._on_player_scene_body_entered):
		body_entered.connect(controller._on_player_scene_body_entered) 


# GODOT MULTIPLAYER
func _enter_tree() -> void:
	print("Player create in status = " + str(MpGameManager.multiplayer_status))


func register_authority() -> void:
	if MpGameManager.multiplayer_status == 1 || MpGameManager.multiplayer_status == 2 :
		set_multiplayer_authority(peer_id)
		print("")
		print("Set authority to = " + str(peer_id))
		var player_id = name.replace("Player", "")
		print("Name to int = " + player_id)
		player_index = player_id.to_int()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# On disconect, avoids error of trying to acess a multplayer that doesn't exist
	if multiplayer.has_multiplayer_peer():
		var peer = multiplayer.multiplayer_peer
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			if _is_first_disconnect_message:
				print("[Player multiplayer error] Not active")
				_is_first_disconnect_message = false
			return 
			
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	controller.integrate_forces(state)
