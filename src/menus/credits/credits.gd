extends Control

@onready var credits = $"."


func _on_back_menu_button_pressed():
	AudioManager.play_audio("ButtonAccept")
	credits.visible = false


func _on_back_menu_button_mouse_entered():
	AudioManager.play_audio("ButtonDecline")
