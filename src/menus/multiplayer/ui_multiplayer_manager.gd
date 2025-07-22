extends Control

@export var address : String = "127.0.0.1"
@export var port : int = 8910

@export var player_scene : PackedScene

#@onready var game_scene : PackedScene = preload("res://src/main_scenes/mp_stage.tscn")
@onready var hosting_indicator: Label = %HostingIndicator
@onready var player_1: AnimatedSprite2D = %Player1
@onready var player_2: AnimatedSprite2D = %Player2
@onready var start_game_button: Button = %StartGameButton
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton

@onready var ip_text_edit: LineEdit = %IPTextEdit
@onready var port_text_edit: LineEdit = %PortTextEdit

@onready var multiplayer_logic: Node2D = %MultiplayerLogic

var peer
var number_of_players_connected : int = 0
var _compression_type = ENetConnection.COMPRESS_RANGE_CODER


func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	
	start_game_button.hide()
	join_button.show()
	
	# Connects button to hear sound on mouse entered
	host_button.mouse_entered.connect(_on_mouse_entered)
	start_game_button.mouse_entered.connect(_on_mouse_entered)
	join_button.mouse_entered.connect(_on_mouse_entered)
	back_button.mouse_entered.connect(_on_mouse_entered)


func _update_adress_and_port():
	address = ip_text_edit.text
	port = int(port_text_edit.text)
	print("IP: ", address, ":", port)


#region ButtonCalls
func _on_host_button_pressed():
	_update_adress_and_port()
	var result = multiplayer_logic.try_host_server(address, port)
	print("Host result = ", result)
	if result == OK:
		_start_hosting()


func _on_join_button_pressed() -> void:
	_update_adress_and_port()
	var result = multiplayer_logic.try_join_client_to_server(address, port)

	
	
func _on_start_game_button_pressed() -> void:
	if multiplayer_logic.try_start_game() == false:
		AudioManager.play_decline_sfx()
		print("[Client Error] Not Enough Players")
		# TODO Display error message in UI
	else:
		print("Starting Game on Host.")
	
	
func _on_back_button_pressed() -> void:
	hide()
	_stop_hosting()
	get_parent().get_parent().start_menu_container.show()
	
#endregion

#region ActionsDone


func _start_hosting() -> void:
	MpGameManager.multiplayer_status = 1
	print("Waiting for players!")
#	TODO Separate into function
	hosting_indicator.start_hosting()
	player_1.show()
	start_game_button.show()
	join_button.hide()
	_peer_connected()


func _stop_hosting() -> void:
	MpGameManager.multiplayer_status = -1
	hosting_indicator.stop_hosting()
	player_1.hide()
	start_game_button.hide()
	join_button.show()
	_peer_disconnected(MpGameManager.HOST_ID)


func _update_client_ui_information() -> void:
	if MpGameManager.mp_players.has(1):
		player_1.show()
	if MpGameManager.mp_players.size() > 1:
		player_2.show()
	host_button.disabled = true
	start_game_button.disabled = true


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
		_update_client_ui_information()

# any peer, everyone will call this rpc
# call local, localling calling this function
@rpc("any_peer","call_local")
func start_game() -> void:
	print("Game Start with " + str(number_of_players_connected) + " players.")
	#get_tree().change_scene_to_packed(game_scene)
	print("TODO START GAME")

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
	send_player_information.rpc_id(1, "", multiplayer.get_unique_id())


# Gets fired only from client	
func _connection_failed() -> void:
	print("Could not connect!")

#endregion

func _on_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
