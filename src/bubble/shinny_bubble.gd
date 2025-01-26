extends AnimatedSprite2D

@onready var animated_bubble: AnimatedSprite2D = $"."


func _ready() -> void:

	pass # Replace with function body.

func _shinny(new_value : float):
	animated_bubble.material.set_shader_parameter("blink_intensity", new_value)
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		var tween = get_tree().create_tween()
		tween.tween_method(_shinny, 1.5, 0.0, 1)
