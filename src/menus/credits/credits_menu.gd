extends MarginContainer

signal on_credits_back

@onready var back_button: Button = %BackButton


func _ready():
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_on_mouse_entered)


func _on_back_pressed() -> void:
	AudioManager.play_audio(Global.Sounds.CANCEL_UI)
	self.visible = false
	on_credits_back.emit()


func _on_mouse_entered() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)