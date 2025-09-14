class_name MainMenu
extends Control

@onready var start_game_button: Button = %PlayButton
@onready var multiplayer_button: Button = %MultiplayerButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button: Button = %ExitButton

@onready var start_menu_container: VBoxContainer = $MarginContainer/StartMenuContainer
@onready var multiplayer_container: HBoxContainer = $MarginContainer/MultiplayerContainer

@onready var credits: Control = %Credits
@onready var options_menu: OptionsMenu = %OptionsMenu

@onready var game_scene: PackedScene = preload("res://src/main_scenes/stage.tscn")


func _ready():
	CommandLineArgsHandler.apply_commandline_args()

	_start_main_menu_music()

	options_menu.visible = false
	credits.visible = false
	multiplayer_container.visible = false
	
	
	# Connects buttons to functions
	start_game_button.button_down.connect(_on_start_pressed)
	multiplayer_button.button_down.connect(_on_multiplayer_pressed)
	options_button.button_down.connect(_on_options_pressed)
	credits_button.button_down.connect(_on_credits_pressed)
	exit_button.button_down.connect(_on_exit_pressed)

	start_game_button.mouse_entered.connect(_play_hover_sfx)
	multiplayer_button.mouse_entered.connect(_play_hover_sfx)
	options_button.mouse_entered.connect(_play_hover_sfx)
	credits_button.mouse_entered.connect(_play_hover_sfx)
	exit_button.mouse_entered.connect(_play_hover_sfx)


# --- || Audio || ---
func _start_main_menu_music() -> void:
	AudioManager.play_audio(Global.Sounds.MAIN_MENU_MUSIC)
	AudioManager.play_audio(Global.Sounds.MAIN_MENU_AMBIANCE)


func _stop_main_menu_music() -> void:
	AudioManager.stop_audio(Global.Sounds.MAIN_MENU_MUSIC)
	AudioManager.stop_audio(Global.Sounds.MAIN_MENU_AMBIANCE)


func _play_click_sfx() -> void:
	AudioManager.play_audio(Global.Sounds.ACCEPT_UI)


func _play_hover_sfx() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)


# --- || Button Functions || ---
func _on_start_pressed() -> void:
	_play_click_sfx()
	_stop_main_menu_music()
	get_tree().change_scene_to_packed(game_scene)


func _on_multiplayer_pressed() -> void:
	_play_click_sfx()
	start_menu_container.visible = false
	multiplayer_container.visible = true


func _on_options_pressed() -> void:
	_play_click_sfx()
	options_menu.visible = true


func _on_credits_pressed():
	_play_click_sfx()
	credits.visible = true
	
	
func _on_exit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()
