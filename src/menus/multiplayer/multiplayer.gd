extends Control

@onready var hosting_indicator: Label = $Background/MarginContainer/MultiplayerContainer/MarginContainer/VButtonsContainer/HostingIndicator
@onready var player_1: AnimatedSprite2D = %Player1
@onready var player_2: AnimatedSprite2D = %Player2

var peer
var _compression_type = ENetConnection.COMPRESS_RANGE_CODER
@export var Address = "127.0.0.1"
@export var port = 8910
@export var max_players = 2
@export var player_scene : PackedScene

func _ready() -> void:
	#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

func _on_host_button_pressed():
	peer = ENetMultiplayerPeer.new()
	# Por open on windows by default, check open ports with netstat -aon
	var error = peer.create_server(port, max_players)
	if error != OK:
		print("Cannot Host: " + error)
		return
	
	# Deal with compression types, COMPRESS_RANGE_CODER best for packet smaller than 4kb 
	peer.get_host().compress(_compression_type)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players!")
	hosting_indicator.start_hosting()
	player_1.show()
	
	Global.multiplayer_status = 1
#	adds own player
	_peer_connected()

func _on_join_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(_compression_type)
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.
	
# Gets called on the server and clients, when someone connects
func _peer_connected(id = 1) -> void:
	print("Player Connected " + str(id))
	if id != 1: 
		player_2.show()
		
# Gets called on the server and clients, when someone disconnects
func _peer_disconnected(id) -> void:
	print("Player Disconnected " + str(id))
	
# Gets fired only from client
func _connected_to_server() -> void:
	# Send information to server here
	print("Connected to Server!")

# Gets fired only from client	
func _connection_failed() -> void:
	print("Could not connect!")
