extends Control

@onready var menu_button = %MenuButton

var main_menu_scene : PackedScene

@onready var orange_background: PanelContainer = $OrangeBackground
@onready var yellow_background: PanelContainer = $YellowBackground



func _ready():
	main_menu_scene = load("res://src/menus/MainMenu.tscn")
	menu_button.button_down.connect(_on_menu_pressed)
	set_winner(Global.winner_index != 1)
	AudioManager.play_audio(Global.Sounds.END_MUSIC)

func set_winner(is_orange_winner: bool) -> void:
	yellow_background.visible = !is_orange_winner
	orange_background.visible = is_orange_winner

func orange_wins() -> void:
	yellow_background.visible = false
	orange_background.visible = true
	
func yellow_wins() -> void:
	yellow_background.visible = true
	orange_background.visible = false

# Buttons Actions

func _on_menu_pressed() -> void:
	AudioManager.play_audio(Global.Sounds.ACCEPT_UI)
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_menu_button_mouse_entered() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)
