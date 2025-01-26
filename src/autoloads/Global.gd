extends Node

## Radius of the stage circle (px).
const STAGE_RADIUS = 232

var _rng := RandomNumberGenerator.new()

## LOCATOR VARIABLES

# the "service" node that is responsible for spawning bubbles (see the ready func in stage.gd)
var bubble_spawner


func _ready() -> void:
	randomize()
	_rng.randomize()
