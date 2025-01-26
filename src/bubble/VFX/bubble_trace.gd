extends Sprite2D

@export var starting_alfa = 0.75
@export var alfa_to_remove = 0.01

var current_alfa
var color = Color(1.0, 1.0, 1.0)
var color_alfa


func _ready() -> void:
	current_alfa = starting_alfa
	color_alfa = Color(color, current_alfa)
	modulate = color_alfa


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	current_alfa -= alfa_to_remove
	color_alfa = Color(color, current_alfa)
	modulate = color_alfa
	if current_alfa <= 0:
		queue_free()
