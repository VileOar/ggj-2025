extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
@export var max_players = 2
@export var player_scene : PackedScene


@onready var game_scene : PackedScene = preload("res://testScene.tscn")
@onready var host_btn: Button = %HostBtn
@onready var join_btn: Button = %JoinBtn
@onready var start_game_btn: Button = %StartGameBtn
@onready var player_1: Label = %Player1
@onready var player_2: Label = %Player2
@onready var name_edit: TextEdit = %NameEdit



var peer
var number_of_players_connected : int = 0
var _compression_type = ENetConnection.COMPRESS_RANGE_CODER



func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	
	start_game_btn.disabled = true

#region ButtonCalls

func _on_host_btn_pressed() -> void:
	start_game_btn.disabled = false
	peer = ENetMultiplayerPeer.new()
	# Por open on windows by default, check open ports with netstat -aon
	var error = peer.create_server(port, max_players)
	if error != OK:
		print("Cannot Host: " + error)
		return
	
	# Deal with compression types, COMPRESS_RANGE_CODER best for packet smaller than 4kb 
	peer.get_host().compress(_compression_type)
	
	multiplayer.set_multiplayer_peer(peer)
	_start_hosting()
	
#	adds own player
	send_player_information("", multiplayer.get_unique_id())


func _on_join_btn_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(_compression_type)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game_btn_pressed() -> void:
#	If game doesn't have two players, doen't start
	if not number_of_players_connected == max_players:
		print("Not Enough Players")
		return
	# Display error message in UI
	
#	this function is going to work on a remote procedure call, clal everyone
	start_game.rpc()
	print("Start_Dame_Button on Host with " + str(number_of_players_connected) + " players.")
	
#endregion

#region ActionsDone


func _start_hosting() -> void:
	GameManager.multiplayer_status = 1
	print("Waiting for players!")
	player_1.show()
	_peer_connected()

#@rpc("any_peer", "call_local")
func update_client_ui_information() -> void:
	if GameManager.mp_players.has(1):
		player_1.show()
	if GameManager.mp_players.size() > 1:
		player_2.show()
	host_btn.disabled = true
	start_game_btn.disabled = true

@rpc("any_peer")
func send_player_information(name, id) -> void:
	if !GameManager.mp_players.has(id):
		GameManager.mp_players[id] = {
			"name" : name,
			"id" : id,
			"score" : 0
		}
		
	if multiplayer.is_server():
		for i in GameManager.mp_players:
			send_player_information.rpc(GameManager.mp_players[i].name, i)
	else:
		update_client_ui_information()
		

# any peer, everyone will call this rpc
# call local, localling calling this function
@rpc("any_peer","call_local")
func start_game() -> void:
	print("Game Start with " + str(number_of_players_connected) + " players.")
	get_tree().change_scene_to_packed(game_scene)

#endregion

#region NetworkingCalls
	
# Gets called on the server and clients, when someone connects
func _peer_connected(id = 1) -> void:
	print("Player Connected " + str(id))
	number_of_players_connected += 1
	
	if id != 1: 
		player_2.show()
		
# Gets called on the server and clients, when someone disconnects
func _peer_disconnected(id) -> void:
	print("Player Disconnected " + str(id))
	number_of_players_connected -= 1
	
	if id != 1: 
		player_2.hide()
	
# Gets fired only from client
func _connected_to_server() -> void:
	# Send information to server here
	print("Connected to Server!")
	# Keep track of everyone who is in the server
	send_player_information.rpc_id(1, name_edit.text, multiplayer.get_unique_id())


# Gets fired only from client	
func _connection_failed() -> void:
	print("Could not connect!")

#endregion
