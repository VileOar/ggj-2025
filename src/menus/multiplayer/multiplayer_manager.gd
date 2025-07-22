extends Node2D

var peer
var number_of_players_connected : int = 0
# MpGameManager.COMPRESSION_TYPE


func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)


func try_host_server(address : String, port : String) -> int:
	peer = ENetMultiplayerPeer.new()
	# Por open on windows by default, check open ports with netstat -aon
	var error = peer.create_server(port, MpGameManager.MAX_PLAYERS)
	if error == ERR_CANT_CREATE:
		print("Error - Server already created!")
		return error
	if error != OK:
		print("Cannot Host: " + str(error))
		return error
	
	# Deal with compression types, COMPRESS_RANGE_CODER best for packet smaller than 4kb 
	peer.get_host().compress(MpGameManager.COMPRESSION_TYPE)
	multiplayer.set_multiplayer_peer(peer)
	# Adds own player
	send_player_information("", multiplayer.get_unique_id())
	return OK


func try_join_client_to_server(address : String, port : String) -> int:
	if MpGameManager.mp_players.size() == MpGameManager.MAX_PLAYERS:
		AudioManager.play_decline_sfx()
		print("[Client Error] Max players are connected!")
		return ERR_CANT_CONNECT
		
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		AudioManager.play_decline_sfx()
		print("[Client Error] Cannot Create Client: " + str(error))
		return ERR_CANT_CONNECT 
		
	peer.get_host().compress(MpGameManager.COMPRESSION_TYPE)
	multiplayer.set_multiplayer_peer(peer)
	MpGameManager.multiplayer_status = 2
	return OK
	
func try_start_game() -> bool:
	# If game doesn't have two players, doen't start
	if not number_of_players_connected == MpGameManager.MAX_PLAYERS:
		return false
		AudioManager.play_decline_sfx()
		print("Not Enough Players")
	# TODO Display error message in UI
	else: 
		# This function is going to work on a remote procedure call, call everyone
		start_game.rpc()
		print("Game Start on Host with " + str(number_of_players_connected) + " players.")
		return true
