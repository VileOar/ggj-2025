extends Node

enum Scenes { MAIN_MENU, STAGE, END_SCREEN }

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

## Dictionary with possible screen resolutions
const RESOLUTIONS: Dictionary = {
	"1920x1080[16:9]": Vector2(1920, 1080),
	"1600x900[16:9]": Vector2(1600, 900),
	"1366x768[16:9]": Vector2(1366, 768),
	"1280x720[16:9]": Vector2(1280, 720),
	"1280x1024[5:4]": Vector2(1280, 1024),
	"1280x960[4:3]": Vector2(1280, 960),
	"1024x768[4:3]": Vector2(1024, 768),
}
## Ordered list of resolutio keys i.e. strings
const ORDERED_RESOLUTIONS: Array = [
	"1920x1080[16:9]",
	"1600x900[16:9]",
	"1366x768[16:9]",
	"1280x720[16:9]",
	"1280x1024[5:4]",
	"1280x960[4:3]",
	"1024x768[4:3]",
]

## Volume at which audio is considered inexistent
const AUDIO_OFF_VOLUME := -80.0

## Radius of the stage circle (px).
const STAGE_RADIUS = 232

## Bubble needs to be bigger than this percentage to be considered dangerous
const BUBBLE_IS_DANGEROUS_PERCENTAGE = 0.4

## Tracks the index of the player that won the match
var winner_index = -1

## The "service" node that is responsible for spawning bubbles (see the ready func in stage.gd)
var bubble_spawner_node = null

var _main_menu_scene: PackedScene = preload("res://src/menus/MainMenu.tscn")
var _game_scene: PackedScene = preload("res://src/main_scenes/BattleStage.tscn")
var _end_scene: PackedScene = preload("res://src/menus/victory/VictoryScreen.tscn")


func change_scene(new_scene) -> void:
	match new_scene:
		Scenes.MAIN_MENU:
			get_tree().change_scene_to_packed(_main_menu_scene)
		Scenes.STAGE:
			get_tree().change_scene_to_packed(_game_scene)
		Scenes.END_SCREEN:
			get_tree().change_scene_to_packed(_end_scene)
