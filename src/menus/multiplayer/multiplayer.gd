extends Control


var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func _on_host_pressed():
	# Por open on windows by default, check open ports with netstat -aon
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	Global.multiplayer_status = 1
#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_add_player)
#	adds own player
	_add_player()
	
func _add_player(id = 1) -> void:
	pass
	
	
