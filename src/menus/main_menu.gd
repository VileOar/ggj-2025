class_name MainMenu
extends Control

@onready var start_game_button : Button = %PlayButton
#@onready var credits = %CreditsButton
#@onready var how_to_play = %HowToPlayButton
@onready var exit_button : Button = %ExitButton
@onready var credits: Control = %Credits

@onready var game_scene : PackedScene = preload("res://src/main_scenes/stage.tscn")
@onready var multiplayer_menu : PackedScene = preload("res://src/menus/multiplayer/MultiplayerMenu.tscn")


func _ready():
# Connects buttons to functions
	#start_game_button.grab_focus()
	start_game_button.button_down.connect(_on_start_pressed)
	exit_button.button_down.connect(_on_exit_pressed)


func _play_click_sfx() -> void:
	#SoundManager.instance.play_click_sfx()
	pass


# Starts game
func _on_start_pressed() -> void:
	_play_click_sfx()
	Global.multiplayer_status = 0
	#SoundManager.instance.play_correct_sfx()
	get_tree().change_scene_to_packed(game_scene)


func _on_multiplayer_button_pressed() -> void:
	_play_click_sfx()
	Global.multiplayer_status = 1
	
	get_tree().change_scene_to_packed(multiplayer_menu)

func _on_credits_button_pressed():
	_play_click_sfx()
	credits.visible = true
	
	
# Exists game
func _on_exit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()
