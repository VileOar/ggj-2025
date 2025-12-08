extends Camera2D

# Screen shake vars
@export var trauma_reduction_rate := 1.6
@export var max_x := 60
@export var max_y := 60

@export var noise: FastNoiseLite
@export var noise_speed := 700

var _trauma := 0.0
var _time := 0.0


func _ready():
	Signals.screen_shake.connect(_add_noise)


func _process(delta):
	_time += delta
	_trauma = max(_trauma - delta * trauma_reduction_rate * trauma_reduction_rate, 0.0)

	offset.x = max_x * _trauma * _trauma * _get_noise_from_seed(0)
	offset.y = max_y * _trauma * _trauma * _get_noise_from_seed(1)


func _add_noise(trauma_amount: float):
	_trauma = clamp(_trauma + trauma_amount, 0.0, 1.0)


func _get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(_time * noise_speed)
