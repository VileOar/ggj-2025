extends Node

@export var BUBBLE: PackedScene

@onready var _bubble_holder: Node2D = %BubbleHolder


func _ready() -> void:
	Global.bubble_spawner = self


func spawn_bubble(position: Vector2, impulse: Vector2, scale_percent: float):
	var new_bubble = BUBBLE.instantiate()
	new_bubble.position = position
	_bubble_holder.call_deferred("add_child", new_bubble)
	
	while !new_bubble.is_node_ready():
		await new_bubble.ready
	
	new_bubble.setup_bubble(impulse, scale_percent)
