extends Node

const MIN_VIGNETTE_RADIUS := 0.35
const MAX_VIGNETTE_RADIUS := 0.7

@export var bubble_scene: PackedScene

## Keeps track of concurrent floating crabs
var _float_counter := 0

var _vignette_tween: Tween
var _current_vignette_radius := 0.0

@onready var _bubble_holder: Node2D = %BubbleHolder
@onready var _pause_menu: PauseMenu = %PauseMenu
@onready var _vignette_rect: ColorRect = %Vignette
@onready var _win_interval: Timer = %WinInterval


func _ready() -> void:
	_set_vignette_radius(MAX_VIGNETTE_RADIUS)
	_pause_menu.visible = false
	Global.bubble_spawner_node = self
	Global.winner_index = -1
	AudioManager.play_audio(Global.Sounds.FIGHT_MUSIC)

	Signals.crab_lose.connect(_on_crab_lose)
	Signals.crab_floating.connect(_on_crab_float)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Signals.crab_lose.disconnect(_on_crab_lose)
		Signals.crab_floating.disconnect(_on_crab_float)


func spawn_bubble(position: Vector2, impulse: Vector2, scale_percent: float):
	var new_bubble = bubble_scene.instantiate()
	new_bubble.position = position
	_bubble_holder.call_deferred("add_child", new_bubble)

	while !new_bubble.is_node_ready():
		await new_bubble.ready

	new_bubble.setup_bubble(impulse, scale_percent)


func _on_crab_lose(player_index) -> void:
	_win_interval.start(10)
	Global.winner_index = player_index


func _on_crab_float(entered_state) -> void:
	var cached_counter = _float_counter

	if entered_state:
		_float_counter = _float_counter + 1
	else:
		_float_counter = max(_float_counter - 1, 0)

	if cached_counter != _float_counter:
		if _vignette_tween:
			_vignette_tween.kill()

		_vignette_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

		var cached_radius = _current_vignette_radius
		if _float_counter == 0 or _float_counter > 1:
			_vignette_tween.tween_method(_set_vignette_radius, cached_radius, MAX_VIGNETTE_RADIUS, 1.0)
		else:
			if Global.winner_index < 0:
				_vignette_tween.tween_method(_set_vignette_radius, cached_radius, MIN_VIGNETTE_RADIUS, 0.5)


func _set_vignette_radius(new_radius: float):
	_current_vignette_radius = new_radius
	_vignette_rect.material.set_shader_parameter("MULTIPLIER", new_radius)


func _on_win_interval_timeout() -> void:
	AudioManager.stop_audio(Global.Sounds.FIGHT_MUSIC)
	Global.change_scene(Global.Scenes.END_SCREEN)
