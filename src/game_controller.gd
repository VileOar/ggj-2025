class_name GameController
extends Node2D


@export var BUBBLE: PackedScene

var rng = RandomNumberGenerator.new()


func _ready() -> void:
#	Starts with two bubbles
	spawn_bubble()
	spawn_bubble()


func _process(delta: float) -> void:
#	SPAWN BUBBLE
	if Input.is_action_just_pressed("launch_bubble"):
		spawn_bubble()
	
	
func _set_bubble_connection(new_bubble) -> void:
	new_bubble.big_bubble_collision.connect(_join_bubbles)
	
	
func _join_bubbles() -> void:
	#print("bubbles join")
	pass
	
	
func spawn_bubble():
	randomize()
	var screen_size = get_viewport().get_visible_rect().size
	
	#new_bubble.position = get_viewport().get_mouse_position()
	var new_bubble = BUBBLE.instantiate()
	_set_bubble_connection(new_bubble)
	
#	Random position to spawn
	new_bubble.position.x = randi_range(0, screen_size.x)
	new_bubble.position.y = randi_range(0, screen_size.y)
	
	# adds to scene
	add_child(new_bubble)
