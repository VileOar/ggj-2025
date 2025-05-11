extends PathFollow2D

@onready var path_follow_2d: PathFollow2D = $"."

var path_follow_speed = 0.1

func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta * path_follow_speed
