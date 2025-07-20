class_name PauseMenu
extends Control

@onready var continue_button : Button = %ContinueButton
@onready var options_button : Button = %OptionsButton
@onready var menu_button : Button = %MenuButton
@onready var exit_button : Button = %ExitButton

@onready var _pause_menu = $"."
@onready var _options_menu: OptionsMenu = %OptionsMenu
var main_menu_scene : PackedScene 


func _ready():
	main_menu_scene = load("res://src/menus/MainMenu.tscn")
	_options_menu.visible = false
	
	# Connects buttons to functions
	continue_button.button_down.connect(_on_continue_pressed)
	options_button.button_down.connect(_on_options_pressed)
	menu_button.button_down.connect(_on_menu_pressed)
	exit_button.button_down.connect(_on_exit_pressed)

func _play_click_sfx() -> void:
	AudioManager.instance.play_click_sfx()

## Deals with input to pause the game and show menu
func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		_pause_menu.visible = not _pause_menu.visible
		get_tree().paused = not get_tree().paused


# Starts game
func _on_continue_pressed() -> void:
	_play_click_sfx()
	get_tree().paused = not get_tree().paused
	self.visible = false


func _on_options_pressed() -> void:
	_play_click_sfx()
	_options_menu.visible = true
	
	
func _on_menu_pressed() -> void:
	_play_click_sfx()
	get_tree().paused = false
	AudioManager.instance.stop_audio("Arena")
	get_tree().change_scene_to_packed(main_menu_scene)
	
	
# Exists game
func _on_exit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()
