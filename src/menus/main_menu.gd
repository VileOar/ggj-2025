class_name MainMenu
extends Control

@onready var start_game_button : Button = %PlayButton
#@onready var credits = %CreditsButton
#@onready var how_to_play = %HowToPlayButton
@onready var exit_button : Button = %ExitButton
@onready var credits: Control = %Credits

@onready var game_scene : PackedScene = preload("res://src/main_scenes/stage.tscn")


func _ready():
# Connects buttons to functions
	#start_game_button.grab_focus()
	start_game_button.button_down.connect(_on_start_pressed)
	exit_button.button_down.connect(_on_exit_pressed)


func _play_click_sfx() -> void:
	AudioManager.play_audio("ButtonAccept")


func _play_hover_sfx() -> void:
	AudioManager.play_audio("ButtonDecline")

# Starts game
func _on_start_pressed() -> void:
	_play_click_sfx()
	get_tree().change_scene_to_packed(game_scene)


func _on_credits_button_pressed():
	_play_click_sfx()
	credits.visible = true
	
	
# Exists game
func _on_exit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()


func _on_credits_button_mouse_entered():
	_play_hover_sfx()

func _on_play_button_mouse_entered():
	_play_hover_sfx()

func _on_exit_button_mouse_entered():
	_play_hover_sfx()
