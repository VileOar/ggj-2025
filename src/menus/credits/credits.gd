extends Control


func _on_back_menu_button_pressed():
	AudioManager.play_audio(Global.Sounds.CANCEL_UI)
	visible = false


func _on_back_menu_button_mouse_entered():
	AudioManager.play_audio(Global.Sounds.HOVER_UI)
