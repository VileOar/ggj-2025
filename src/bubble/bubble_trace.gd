extends Sprite2D

const WHITE_COLOR = Color(1.0, 1.0, 1.0)

@export var starting_alfa = 0.75
@export var alfa_to_remove = 0.01

var _current_alfa
var _current_color_alfa


func _ready() -> void:
	_current_alfa = starting_alfa
	_current_color_alfa = Color(WHITE_COLOR, _current_alfa)
	modulate = _current_color_alfa


func _physics_process(_delta: float) -> void:
	_current_alfa -= alfa_to_remove
	_current_color_alfa = Color(WHITE_COLOR, _current_alfa)
	modulate = _current_color_alfa
	if _current_alfa <= 0:
		queue_free()
