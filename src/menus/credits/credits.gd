extends Control

@onready var main_menu: MainMenu = $".."
@onready var credits = $"."


func _on_back_menu_button_pressed():
	main_menu._play_button_decline_sfx()
	credits.visible = false
