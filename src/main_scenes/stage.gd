extends Node

@export var BUBBLE: PackedScene

@export var end_scene: PackedScene

# GODOT MULTIPLAYER
@export var player_scene : PackedScene


@onready var _bubble_holder: Node2D = %BubbleHolder
@onready var _stage_audio_stream: Node2D = %StageAudioStream

@onready var win_interval: Timer = $WinInterval

var _peer_server

func _create_peer_to_peer_server():
	_peer_server = ENetMultiplayerPeer.new()
	# Por open on windows by default, check open ports with netstat -aon
	_peer_server.create_server(135)
	multiplayer.multiplayer_peer = _peer_server
#	When signal peer_connected received, calls add player
	multiplayer.peer_connected.connect(_add_player)
#	adds own player
	_add_player()

	
func _add_player(id = 1) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	

func _ready() -> void:
	Global.bubble_spawner = self
	Global.winner = -1
	if Global.multiplayer_status == 1:
		_create_peer_to_peer_server()
	
	Signals.crab_lose.connect(_on_crab_lose)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Signals.crab_lose.disconnect(_on_crab_lose)


func spawn_bubble(position: Vector2, impulse: Vector2, scale_percent: float):
	var new_bubble = BUBBLE.instantiate()
	new_bubble.position = position
	_bubble_holder.call_deferred("add_child", new_bubble)
	
	while !new_bubble.is_node_ready():
		await new_bubble.ready
	
	new_bubble.setup_bubble(impulse, scale_percent)


func _on_crab_lose(player_index) -> void:
	win_interval.start(10)
	Global.winner = player_index


func _on_win_interval_timeout() -> void:
	get_tree().change_scene_to_packed(end_scene)
