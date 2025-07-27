extends Node

var IS_DEBUGGING : bool = true

# dictionary with possible resolutions
var resolutions: Dictionary = {"1920x1080[16:9]" : Vector2(1920, 1080),
								"1600x900[16:9]" : Vector2(1600, 900),
								"1366x768[16:9]" : Vector2(1366, 768),
								"1280x720[16:9]" : Vector2(1280, 720),
								"1280x1024[5:4]" : Vector2(1280, 1024),
								"1280x960[4:3]"  : Vector2(1280, 960),
								"1024x768[4:3]"  : Vector2(1024, 768),}

# ordered list of keys
var ordered_resolution_keys: Array = [
	"1920x1080[16:9]",
	"1600x900[16:9]",
	"1366x768[16:9]",
	"1280x720[16:9]",
	"1280x1024[5:4]",
	"1280x960[4:3]",
	"1024x768[4:3]",
]
