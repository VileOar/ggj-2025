extends Node

@export var BUBBLE: PackedScene

@onready var _bubble_holder: Node2D = %BubbleHolder
@onready var _pause_menu: PauseMenu = $PauseMenu

@onready var win_interval: Timer = $WinInterval

func _ready() -> void:
	_pause_menu.visible = false
	Global.bubble_spawner_node = self
	Global.winner_index = -1
	AudioManager.play_audio(Global.Sounds.FIGHT_MUSIC)
	
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
	Global.winner_index = player_index


func _on_win_interval_timeout() -> void:
	AudioManager.stop_audio(Global.Sounds.FIGHT_MUSIC)
	Global.change_scene(Global.Scenes.END_SCREEN)
