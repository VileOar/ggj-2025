extends Node2D

@export var BUBBLE: PackedScene

func _process(delta: float) -> void:
#	SPAWN BUBBLE
	if Input.is_action_just_pressed("launch_bubble"):
		spawn_bubble()
	

func spawn_bubble():
	randomize()
	
	#new_bubble.position = get_viewport().get_mouse_position()
	var new_bubble = BUBBLE.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	
#	Random position to spawn
	new_bubble.position.x = randi_range(0, screen_size.x)
	new_bubble.position.y = randi_range(0, screen_size.y)
	
	# adds to scene
	add_child(new_bubble)
