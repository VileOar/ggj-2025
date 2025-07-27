extends Node2D

const VISIBLE := true
const HIDDEN := false

@onready var game_scene : PackedScene = preload("res://src/main_scenes/mp_stage.tscn")
var peer
var number_of_players_connected : int = 0

signal update_connected_players()
signal updates_player_id_status(player_id : int, is_visible : bool)

# the multiplayer ui is coupled to the logic
# Logic is not coupled to ui

func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

#region TryHostJoinStartGame



func try_host_server(_address : String, port : int) -> int:
	peer = ENetMultiplayerPeer.new()
	# Por open on windows by default, check open ports with netstat -aon
	if not UtilsNetwork.is_port_available_in_machine_ip(port):
		print("[Server Error] Port in IP is already used")
		return ERR_CANT_CREATE
		
	var error = peer.create_server(port, MpGameManager.MAX_PLAYERS)
	if error == ERR_CANT_CREATE:
		print("Error - Server already exists in the same IP!")
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
		print("[Client Error] Max players are connected!")
		return ERR_CANT_CONNECT
		
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("[Client Error] Cannot Create Client: " + str(error))
		return ERR_CANT_CONNECT 
		
	peer.get_host().compress(MpGameManager.COMPRESSION_TYPE)
	multiplayer.set_multiplayer_peer(peer)
	MpGameManager.multiplayer_status = 2
	return OK
	
func try_start_game() -> bool:
	# If game doesn't have two players, doen't start
	if not number_of_players_connected == MpGameManager.MAX_PLAYERS:
		print("Not Enough Players")
		return false
	else: 
		# This function is going to work on a remote procedure call, call everyone
		start_game.rpc()
		print("Game Start on Host with " + str(number_of_players_connected) + " players.")
		return true

#endregion

func start_hosting() -> void:
	MpGameManager.multiplayer_status = 1
	_peer_connected()
	
	
func stop_hosting() -> void:
	MpGameManager.multiplayer_status = -1
	_peer_disconnected(multiplayer.get_unique_id())
	close_server_connection()
	
	
func close_server_connection() -> void:
	if multiplayer.multiplayer_peer:
		# Close the peer
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		print("Server connection has been shut down.")


@rpc("any_peer")
func send_player_information(player_name, id) -> void:
	if !MpGameManager.mp_players.has(id):
		MpGameManager.mp_players[id] = {
			"name" : player_name,
			"id" : id,
			"score" : 0
		}
		
	if multiplayer.is_server():
		print("[Server][Send Player Information] MpGameManager.mp_players: ", MpGameManager.mp_players)
		for i in MpGameManager.mp_players:
			send_player_information.rpc(MpGameManager.mp_players[i].name, i)
	else:
		emit_signal("update_connected_players")
		if id != MpGameManager.HOST_ID:
			print("[Client ", id, "][Send Player Information] MpGameManager.mp_players: ", MpGameManager.mp_players)
		
	
# any peer, everyone will call this rpc
# call local, localling calling this function
@rpc("any_peer","call_local")
func start_game() -> void:
	print("Game Start with " + str(number_of_players_connected) + " players.")
	get_tree().change_scene_to_packed(game_scene)
	
	
#region NetworkingCalls
	
# Gets called on the server and clients, when someone connects
func _peer_connected(id = MpGameManager.HOST_ID) -> void:
	print("[Connected] Player Connected " + str(id))
	number_of_players_connected += 1
	
	if id != MpGameManager.HOST_ID: 
		emit_signal("updates_player_id_status", MpGameManager.SECOND_PLAYER, VISIBLE)
		
		
# Gets called on the server and clients, when someone disconnects
func _peer_disconnected(id) -> void:
	print("[DisConnected] Player Disconnected " + str(id))
	number_of_players_connected -= 1
	MpGameManager.mp_players.erase(id)
	
	if id != MpGameManager.HOST_ID: 
		emit_signal("updates_player_id_status", MpGameManager.SECOND_PLAYER, HIDDEN)
	
	
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
