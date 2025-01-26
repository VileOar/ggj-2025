extends Control

@onready var how_to_play = $"."


func _on_back_menu_button_pressed():
	how_to_play.visible = false
