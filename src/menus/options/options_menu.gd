class_name OptionsMenu
extends Control

#@onready var start_game_button : Button = $Background/MarginContainer/HorizontalContainer/MarginContainer/VButtonsContainer/PlayButton
@onready var back_button : Button = $MarginContainer/HorizontalContainer/MarginContainer/VButtonsContainer/BackContainer/BackButton
@onready var resolution_dropdown_button = $MarginContainer/HorizontalContainer/MarginContainer/VButtonsContainer/ResolutionContainer/ResolutionDropdown
@onready var resolution_label: Label = %ResolutionLabel

@onready var resolution_left_btn: Button = %ResolutionLeftBtn
@onready var resolution_right_btn: Button = %ResolutionRightBtn


var _current_window_position


func _ready():
# Saves initial center position of primary screen so that it can add up the new position to it 
# in the future
	_current_window_position = DisplayServer.window_get_position()
# Connects buttons to functions
	back_button.button_down.connect(_on_back_pressed)
	resolution_dropdown_button.button_down.connect(_on_resolution_clicked)
	resolution_dropdown_button.item_selected.connect(_on_resolution_selected)
	
	resolution_left_btn.item_selected.connect(_on_resolution_left_btn)
	resolution_right_btn.item_selected.connect(_on_resolution_right_btn)
	
	
	# TODO remove this temp resolution setup
	#_on_resolution_selected(6)

func _play_click_sfx() -> void:
	AudioManager.instance.play_click_sfx()


# back to main menu
func _on_back_pressed() -> void:
	_play_click_sfx()
	self.visible = false

# plays sound when clicked
func _on_resolution_clicked() -> void:
	_play_click_sfx()


# resolution selected
func _on_resolution_selected(id) -> void:
	_play_click_sfx()
	#SoundManager.instance.play_correct_sfx()
# Get resolution from Constants ids pre saved
	#var resolutions_keys = Constants.resolutions.keys()
	#var resolution_text = resolutions_keys[id]
	#var resolution_size = Constants.resolutions.get(resolution_text)
	#set_resolution(resolution_size)
	
	
# change screen resolution
func set_resolution(new_resolution: Vector2):
# gets center of the current screen size
	#var center_window_position = Util.get_new_window_position(new_resolution)
	
# adds up screen size of center of a screen to the new position
	#DisplayServer.window_set_position(_current_window_position + center_window_position)
	#print("position = ", _current_window_position)
	#print("position = ", center_window_position)
	#DisplayServer.window_set_size(new_resolution)
	#get_viewport().set_size(new_resolution) 
	pass
