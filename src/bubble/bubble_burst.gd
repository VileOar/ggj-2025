extends AnimatedSprite2D

@onready var _pop_stream: AudioStreamPlayer2D = %PopStream


func _ready():
	var lambda = func(): _pop_stream.play()
	AudioManager.play_with_delay(Global.Sounds.BUBBLE_POP, 0.07, lambda)


func _on_animation_finished() -> void:
	queue_free()
