extends Node2D

const VISIBLE := true
const HIDDEN := false

var peer
var number_of_players_connected : int = 0
# MpGameManager.COMPRESSION_TYPE

signal update_connected_palyers()
signal updates_player_id_status(player_id : int, is_visible : bool)

func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)


func try_host_server(address : String, port : int) -> int:
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


func try_join_client_to_server(address : String, port : int) -> int:
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

func start_hosting() -> void:
	MpGameManager.multiplayer_status = 1
	_peer_connected()
	
func stop_hosting() -> void:
	MpGameManager.multiplayer_status = -1
	_peer_disconnected(MpGameManager.HOST_ID)


@rpc("any_peer")
func send_player_information(player_name, id) -> void:
	if !MpGameManager.mp_players.has(id):
		MpGameManager.mp_players[id] = {
			"name" : player_name,
			"id" : id,
			"score" : 0
		}
		
	if multiplayer.is_server():
		for i in MpGameManager.mp_players:
			send_player_information.rpc(MpGameManager.mp_players[i].name, i)
	else:
		emit_signal("update_connected_palyers")
		#_update_client_ui_information()

# any peer, everyone will call this rpc
# call local, localling calling this function
@rpc("any_peer","call_local")
func start_game() -> void:
	print("Game Start with " + str(number_of_players_connected) + " players.")
	#get_tree().change_scene_to_packed(game_scene)
	print("TODO START GAME")
	
#region NetworkingCalls
	
# Gets called on the server and clients, when someone connects
func _peer_connected(id = 1) -> void:
	print("Player Connected " + str(id))
	number_of_players_connected += 1
	
	if id != 1: 
		emit_signal("updates_player_id_status", MpGameManager.SECOND_PLAYER, VISIBLE)
		#player_2.show()
		
		
# Gets called on the server and clients, when someone disconnects
func _peer_disconnected(id) -> void:
	print("Player Disconnected " + str(id))
	number_of_players_connected -= 1
	
	if id != 1: 
		emit_signal("updates_player_id_status", MpGameManager.SECOND_PLAYER, HIDDEN)
		#player_2.hide()
	
	
# Gets fired only from client
func _connected_to_server() -> void:
	# Send information to server here
	print("Connected to Server!")
	# Keep track of everyone who is in the server
	send_player_information.rpc_id(1, "", multiplayer.get_unique_id())


# Gets fired only from client	
func _connection_failed() -> void:
	print("Could not connect!")

#endregion
