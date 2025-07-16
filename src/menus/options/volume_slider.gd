extends HSlider

@export var bus_name: String

var _bus_index: int


func _ready() -> void:
	_bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	# value => value from hSlider
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(new_value))
