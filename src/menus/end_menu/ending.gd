extends Control

@onready var menu_button = %MenuButton

var main_menu_scene : PackedScene


func _ready():
	main_menu_scene = load("res://src/menus/MainMenu.tscn")
	menu_button.button_down.connect(_on_menu_pressed)


func _on_menu_pressed() -> void:
	#_play_click_sfx()
	get_tree().change_scene_to_packed(main_menu_scene)
