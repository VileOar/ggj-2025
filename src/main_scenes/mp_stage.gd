extends Node

@export var BUBBLE: PackedScene

@export var end_scene: PackedScene

# GODOT MULTIPLAYER
@export var player_1_scene : PackedScene
@export var player_2_scene : PackedScene

@onready var _stage_holder: Node2D = $StageHolder
@onready var player_1_spawn: Node2D = $StageHolder/SpawnLocation1
@onready var player_2_spawn: Node2D = $StageHolder/SpawnLocation2
@onready var _bubble_holder: Node2D = %BubbleHolder

@onready var win_interval: Timer = $WinInterval

var _number_of_players = 0
var _client_player = -1

func _ready() -> void:
	Global.bubble_spawner = self
	Global.winner = -1
	if (MpGameManager.multiplayer_status == 1 || MpGameManager.multiplayer_status == 2):
		_add_mp_players()
	
	Signals.crab_lose.connect(_on_crab_lose)
	
	
func _add_mp_players() -> void:
	# Note: not scalable like this, because shit code
	if !MpGameManager.mp_players.size() == 2:
		print("ERROR - Not enough players connected")
		return
			
	for i in MpGameManager.mp_players:
		var current_player
		var spawn_location
		if i == 1:
			current_player = player_1_scene.instantiate()
			spawn_location = player_1_spawn
		else:
			current_player = player_2_scene.instantiate()
			spawn_location = player_2_spawn
			
		var current_index = str(_number_of_players + 1)
		current_player.name = "Player" + current_index
		current_player.peer_id = MpGameManager.mp_players[i].id
		_stage_holder.add_child(current_player)
		current_player.global_position = spawn_location.global_position
		_number_of_players += 1
		
	#_add_player(player_1_scene, player_1_spawn)
	#_add_player(player_2_scene, player_2_spawn)
	
	
func _add_player(player : PackedScene, spawn_location : Node2D):
	var current_index = str(_number_of_players + 1)
	print("player " + current_index + " spawning in " + str(spawn_location.global_position))
	var current_player = player.instantiate()
	current_player.name = "Player" + current_index
	current_player.peer_id = MpGameManager.mp_players[current_index].id
	#spawn_location.add_child(current_player)
	_stage_holder.add_child(current_player)
	current_player.global_position = spawn_location.global_position
	_number_of_players += 1
	

func _remove_player() -> void:
	_client_player.call_deferred("queue_free")
	print("removed player")
	_number_of_players -= 1


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
