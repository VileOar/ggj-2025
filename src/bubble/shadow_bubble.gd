extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("BubbleShadow")


func destroy_bubble() -> void:
	queue_free()
