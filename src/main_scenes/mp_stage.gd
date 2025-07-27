extends Node

@export var BUBBLE: PackedScene

@export var end_scene: PackedScene

@onready var _bubble_holder: Node2D = %BubbleHolder
@onready var _pause_menu: PauseMenu = $PauseMenu

@onready var win_interval: Timer = $WinInterval

# GODOT MULTIPLAYER
const PlayerSpawnPointGroup = "PlayerSpawnPoint"
@export var player_scene : PackedScene
@onready var _stage_holder: Node2D = $StageHolder
var _spawn_locations
var _number_of_players = 0


func _ready() -> void:
	_pause_menu.visible = false
	Global.bubble_spawner = self
	Global.winner = -1
	AudioManager.instance.play_audio("Arena")
	_check_if_game_is_multiplayer()
	
	Signals.crab_lose.connect(_on_crab_lose)


func _check_if_game_is_multiplayer() -> void:
	_spawn_locations = get_tree().get_nodes_in_group(PlayerSpawnPointGroup)
	if (MpGameManager.multiplayer_status == 1 || MpGameManager.multiplayer_status == 2):
		_add_mp_players()
		
	if Constants.IS_DEBUGGING && multiplayer.get_unique_id() == MpGameManager.HOST_ID:
		$HostLabel.visible = true



func _add_mp_players() -> void:
	# Checks if max players are avaiable
	if !MpGameManager.mp_players.size() == MpGameManager.MAX_PLAYERS:
		print("[GAME ERROR] Not enough players connected")
		return
	
	# Adds each player to the existing position
	# Note: existing position has adjustment
	for i in MpGameManager.mp_players:
		var current_player
		var spawn_location
		var current_index = str(_number_of_players + 1)
		spawn_location = _spawn_locations[_number_of_players]
		
		current_player = player_scene.instantiate()
		current_player.name = "Player" + current_index
		current_player.global_position = spawn_location.global_position
		current_player.rotation = 270.0 if current_index == "1" else 90.0
			
		current_player.peer_id = MpGameManager.mp_players[i].id
		_stage_holder.add_child(current_player)
		_stage_holder.move_child(current_player, _number_of_players)
		_number_of_players += 1
		current_player.register_authority()


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
	AudioManager.instance.stop_audio("Arena")
	get_tree().change_scene_to_packed(end_scene)
