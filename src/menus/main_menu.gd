class_name MainMenu
extends Control

@onready var start_game_button : Button = %PlayButton
@onready var credits_button = %CreditsButton
@onready var exit_button : Button = %ExitButton

@onready var credits: Control = %Credits

@onready var game_scene : PackedScene = preload("res://src/main_scenes/stage.tscn")


func _ready():
	_start_main_menu_music()
	
	# Connects buttons to functions
	start_game_button.button_down.connect(_on_start_pressed)
	credits_button.button_down.connect(_on_credits_pressed)
	exit_button.button_down.connect(_on_exit_pressed)

# Audio
func _start_main_menu_music() -> void:
	AudioManager.instance.play_audio("Ambience")
	AudioManager.instance.play_audio("MainMenuMusic")
	
func _stop_main_menu_music() -> void:
	AudioManager.instance.stop_audio("Ambience")
	AudioManager.instance.stop_audio("MainMenuMusic")

func _play_click_sfx() -> void:
	AudioManager.instance.play_audio("ButtonAccept")

func _play_hover_sfx() -> void:
	AudioManager.play_audio("ButtonDecline")

# Button actions

func _on_start_pressed() -> void:
	_play_click_sfx()
	_stop_main_menu_music()
	get_tree().change_scene_to_packed(game_scene)


func _on_credits_pressed():
	_play_click_sfx()
	credits.visible = true
	
	
func _on_exit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()


func _on_credits_button_mouse_entered():
	_play_hover_sfx()

func _on_play_button_mouse_entered():
	_play_hover_sfx()

func _on_exit_button_mouse_entered():
	_play_hover_sfx()
