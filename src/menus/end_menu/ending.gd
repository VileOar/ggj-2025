extends Control

@onready var menu_button = %MenuButton

var main_menu_scene : PackedScene

@onready var orange_background: PanelContainer = $OrangeBackground
@onready var yellow_background: PanelContainer = $YellowBackground



func _ready():
	main_menu_scene = load("res://src/menus/MainMenu.tscn")
	menu_button.button_down.connect(_on_menu_pressed)

func set_winner(is_orange_winner: bool) -> void:
	yellow_background.visible = !is_orange_winner
	orange_background.visible = is_orange_winner

func orange_wins() -> void:
	yellow_background.visible = false
	orange_background.visible = true
	
func yellow_wins() -> void:
	yellow_background.visible = true
	orange_background.visible = false

func _on_menu_pressed() -> void:
	#_play_click_sfx()
	get_tree().change_scene_to_packed(main_menu_scene)
