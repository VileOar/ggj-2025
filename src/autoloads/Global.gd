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

enum Scenes {
	MAIN_MENU,
	STAGE,
	END_SCREEN
}

## LOCATOR VARIABLES
# The "service" node that is responsible for spawning bubbles (see the ready func in stage.gd)
var bubble_spawner_node = null

var main_menu_scene: PackedScene = preload("res://src/menus/MainMenu.tscn")
var game_scene: PackedScene = preload("res://src/main_scenes/BattleStage.tscn")
var end_scene: PackedScene = preload("res://src/menus/victory/VictoryScreen.tscn")


func _ready() -> void:
	randomize()
	_rng.randomize()


func change_scene(new_scene) -> void:
	match new_scene:
		Scenes.MAIN_MENU:
			get_tree().change_scene_to_packed(main_menu_scene)
		Scenes.STAGE:
			get_tree().change_scene_to_packed(game_scene)
		Scenes.END_SCREEN:
			get_tree().change_scene_to_packed(end_scene)
