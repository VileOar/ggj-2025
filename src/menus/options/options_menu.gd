class_name OptionsMenu
extends Control

@onready var back_button: Button = %BackButton
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_left_btn: Button = %ResolutionLeftBtn
@onready var resolution_right_btn: Button = %ResolutionRightBtn

@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/MasterVolumeContainer/SliderContainer/MasterSlider
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/MusicVolumeContainer3/SliderContainer/MusicSlider
@onready var sound_slider: HSlider = $MarginContainer/VBoxContainer/SoundVolume/SliderContainer/SoundSlider


var _current_window_position
var _current_resolution_key : String 
var _current_resolution_index : int 


func _ready():
	# Saves initial center position of primary screen so that it can add up the new position to it 
	# in the future
	_current_window_position = DisplayServer.window_get_position()
	_current_resolution_key = _get_closest_resolution_id()
	_current_resolution_index = Constants.ordered_resolution_keys.find(_current_resolution_key)
	resolution_label.text = _current_resolution_key
	
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


## Deals with input to pause the game and show menu
func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		if visible:  
			_play_click_sfx()
		self.visible = false


func _play_click_sfx() -> void:
	AudioManager.instance.play_click_sfx()


# Back to main menu
func _on_back_pressed() -> void:
	_play_click_sfx()
	self.visible = false


func _get_closest_resolution_id() -> String:
	var current_resolution: Vector2i = DisplayServer.window_get_size()
	var closest_key: String = ""
	var smallest_distance: float = INF
	
	# Search for avaiable resolitions and saves vector distance
	for key in Constants.resolutions:
		var res: Vector2i = Constants.resolutions[key]
		var distance: float = current_resolution.distance_to(res)
		
		# Stores smallest distance
		if distance < smallest_distance:
			smallest_distance = distance
			closest_key = key
	
	return closest_key


# change resolution
func _on_resolution_change(res_step : int) -> void:
	_play_click_sfx()
	_set_next_valid_resolution_index(res_step)
	
	var resolution_text = Constants.ordered_resolution_keys[_current_resolution_index]
	resolution_label.text = resolution_text
	
	var resolution_size = Constants.resolutions.get(resolution_text)
	_set_resolution(resolution_size, resolution_text)


func _set_next_valid_resolution_index(res_step : int) -> void:
	var next_id = res_step + _current_resolution_index
	# If next number is higher than the array, resets
	# If it is smaller than 0, it is the last resolution
	if next_id >= Constants.ordered_resolution_keys.size(): 
		next_id = 0
	elif next_id < 0 :
		next_id = Constants.ordered_resolution_keys.size() - 1
	
	_current_resolution_index = next_id


# Change screen resolution and repositions Windows
func _set_resolution(new_resolution: Vector2, resolution_text : String):
	# adds up screen size of center of a screen to the new position
	DisplayServer.window_set_size(new_resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_viewport().set_size(new_resolution) 
	
	# Center the Window on current screen size
	var center_window_position = Utils.get_new_window_position(new_resolution)
	DisplayServer.window_set_position(_current_window_position + center_window_position)
	
	if _current_resolution_key == resolution_text:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#print("position = ", _current_window_position)
	#print("position = ", center_window_position)


func _on_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
