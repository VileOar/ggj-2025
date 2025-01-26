extends Control

@onready var credits = $"."


func _on_back_menu_button_pressed():
	credits.visible = false
