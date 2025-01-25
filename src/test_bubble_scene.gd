extends Node2D

@export var BUBBLE: PackedScene

var rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:
#	SPAWN BUBBLE
	if Input.is_action_just_pressed("launch_bubble"):
		spawn_bubble()
	
	
func _set_random_scale(new_bubble) -> void: 
	var scale_tmp = rng.randf_range(0.5, 1.5)
	new_bubble.scale = Vector2(scale_tmp, scale_tmp)
	print("scale applied: ", scale_tmp)


func spawn_bubble():
	randomize()
	
	#new_bubble.position = get_viewport().get_mouse_position()
	var new_bubble = BUBBLE.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	
#	set Random Scale
	_set_random_scale(new_bubble)
	
#	Random position to spawn
	new_bubble.position.x = randi_range(0, screen_size.x)
	new_bubble.position.y = randi_range(0, screen_size.y)
	
	# adds to scene
	add_child(new_bubble)
