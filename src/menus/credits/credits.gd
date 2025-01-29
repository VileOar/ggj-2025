extends Control

@onready var credits = $"."


func _on_back_menu_button_pressed():
	credits.visible = false
	AudioManager.play_audio("ButtonAccept")


func _on_back_menu_button_mouse_entered():
	AudioManager.play_audio("ButtonDecline")
