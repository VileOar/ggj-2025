class_name MainMenu
extends Control

@onready var start_game_button: Button = %PlayButton
@onready var multiplayer_button: Button = %MultiplayerButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button: Button = %ExitButton

@onready var start_menu: VBoxContainer = $StartMenu
@onready var multiplayer_container: HBoxContainer = $MultiplayerMenu
@onready var options_menu = $OptionsMenu
@onready var credits_menu: Control = $CreditsMenu


func _ready():
	CommandLineArgsHandler.apply_commandline_args()

	AudioManager.play_audio(Global.Sounds.MAIN_MENU_MUSIC)
	AudioManager.play_audio(Global.Sounds.MAIN_MENU_AMBIANCE)

	multiplayer_container.visible = false
	options_menu.visible = false
	credits_menu.visible = false
	
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
	Global.change_scene(Global.Scenes.STAGE)


func _on_multiplayer_pressed() -> void:
	_play_click_sfx()
	start_menu.visible = false
	multiplayer_container.visible = true


func _on_options_pressed() -> void:
	_play_click_sfx()
	start_menu.visible = false
	options_menu.visible = true


func _on_credits_pressed():
	_play_click_sfx()
	start_menu.visible = false
	credits_menu.visible = true
	
	
func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_menu_on_options_back():
	start_menu.visible = true


func _on_credits_menu_on_credits_back():
	start_menu.visible = true
