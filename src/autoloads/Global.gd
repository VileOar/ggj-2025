extends Node

## Radius of the stage circle (px).
const STAGE_RADIUS = 232

var _rng := RandomNumberGenerator.new()

var winner_index = -1

enum Sounds {  
	ACCEPT_UI,      
	CANCEL_UI,
	HOVER_UI,
	MAIN_MENU_MUSIC,
	MAIN_MENU_AMBIANCE,
	FIGHT_MUSIC,
	FIGHT_AMBIANCE,
	FIGHT_CLASH,
	FINAL_IMPACT,
	END_JINGLE,
	END_MUSIC, 
	BUBBLE_SHOOT,
	BUBBLE_BOUNCE,
	BUBBLE_POP
} 

## LOCATOR VARIABLES
# The "service" node that is responsible for spawning bubbles (see the ready func in stage.gd)
var bubble_spawner_node = null


func _ready() -> void:
	randomize()
	_rng.randomize()
