extends Control

@onready var credits = $"."

## Deals with input to pause the game and show menu
func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		if visible :
			AudioManager.play_click_sfx()
			
		credits.visible = false

func _on_back_menu_button_pressed():
	AudioManager.play_audio("ButtonAccept")
	credits.visible = false


func _on_back_menu_button_mouse_entered():
	AudioManager.play_audio("ButtonDecline")
