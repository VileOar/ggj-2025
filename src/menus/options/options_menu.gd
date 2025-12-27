class_name OptionsMenu
extends MarginContainer

signal on_options_back

var _initial_resolution_key: String
var _current_resolution_index: int

@onready var back_button: Button = %BackButton
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_left_btn: Button = %ResolutionLeftBtn
@onready var resolution_right_btn: Button = %ResolutionRightBtn

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sound_slider: HSlider = %SoundSlider


func _ready():
	_initial_resolution_key = _get_closest_resolution_id()

	_current_resolution_index = Global.ORDERED_RESOLUTIONS.find(_initial_resolution_key)
	resolution_label.text = _initial_resolution_key

	# Connects to functions
	back_button.pressed.connect(_on_back_pressed)
	resolution_left_btn.pressed.connect(_on_resolution_change.bind(-1))
	resolution_right_btn.pressed.connect(_on_resolution_change.bind(1))

	# Connects hover sfx
	back_button.mouse_entered.connect(_on_mouse_entered)
	resolution_left_btn.mouse_entered.connect(_on_mouse_entered)
	resolution_right_btn.mouse_entered.connect(_on_mouse_entered)
	master_slider.mouse_entered.connect(_on_mouse_entered)
	music_slider.mouse_entered.connect(_on_mouse_entered)
	sound_slider.mouse_entered.connect(_on_mouse_entered)


func _get_closest_resolution_id() -> String:
	var current_resolution: Vector2i = DisplayServer.window_get_size()
	var closest_key: String = ""
	var smallest_distance: float = INF

	# Search for avaiable resolutions and saves vector distance
	for key in Global.RESOLUTIONS:
		var res: Vector2i = Global.RESOLUTIONS[key]
		var distance: float = current_resolution.distance_to(res)

		# Stores smallest distance
		if distance < smallest_distance:
			smallest_distance = distance
			closest_key = key

	return closest_key


## Returns the top left corner at which to place the window
func _get_new_window_position(new_resolution: Vector2) -> Vector2i:
	var screen_size: Vector2 = DisplayServer.screen_get_size()
	var res_size: Vector2 = new_resolution

	var window_x: float = (screen_size.x / 2) - (res_size.x / 2)
	var window_y: float = (screen_size.y / 2) - (res_size.y / 2)

	return Vector2i(int(window_x), int(window_y))


# --- || Resolution || ---


func _on_resolution_change(res_step: int) -> void:
	AudioManager.play_audio(Global.Sounds.ACCEPT_UI)

	_current_resolution_index = (_current_resolution_index - res_step) % Global.ORDERED_RESOLUTIONS.size()
	var resolution_text = Global.ORDERED_RESOLUTIONS[_current_resolution_index]
	resolution_label.text = resolution_text

	var resolution_size = Global.RESOLUTIONS.get(resolution_text)
	_set_resolution(resolution_size, resolution_text)


## Change screen resolution and repositions window
func _set_resolution(new_resolution: Vector2, resolution_text: String):
	# Adds up screen size of center of a screen to the new position
	DisplayServer.window_set_size(new_resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_viewport().set_size(new_resolution)

	# Center the Window on current screen size
	var center_window_position = _get_new_window_position(new_resolution)
	DisplayServer.window_set_position(center_window_position)

	if _initial_resolution_key == resolution_text:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


# --- || Signals || ---


func _on_back_pressed() -> void:
	AudioManager.play_audio(Global.Sounds.CANCEL_UI)
	self.visible = false
	on_options_back.emit()


func _on_mouse_entered() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)
