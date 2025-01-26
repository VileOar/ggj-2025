extends AnimatedSprite2D

@onready var animated_bubble: AnimatedSprite2D = $"."
@onready var shadow_bubble: Sprite2D = $ShadowBubble


var _is_vfx_active = false

	
func _shine(new_value : float):
	animated_bubble.material.set_shader_parameter("blink_intensity", new_value)


func _activate_vfx_shine() -> void:
	if !_is_vfx_active:
		var _tween = create_tween()
	#	Loops infinitly
		_tween.set_loops()
		_tween.tween_method(_shine, 0.25, 0.8, 1)
		_tween.tween_method(_shine, 0.8, 0.25, 1)
		_is_vfx_active = true
