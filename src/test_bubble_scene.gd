extends Node2D

#const BUBBLE = preload("res://src/bubble/bubble.tscn")
@export var BUBBLE: PackedScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("launch_bubble"):
		spawn_bubble()
	
	

func spawn_bubble():
	var new_bubble = BUBBLE.instantiate()
	#new_bubble.position = get_viewport().get_mouse_position()
	randomize()
	var screen_size = get_viewport().get_visible_rect().size
	print(screen_size.x)
	print(screen_size.y)
	var x = randi_range(0,screen_size.x)
	var y = randi_range(0, screen_size.y)
	new_bubble.position.x = x
	new_bubble.position.y = y
	add_child(new_bubble)
