class_name CommandLineArgsHandler
extends Node


func get_center_position_on_main_screen(screen_index: int, window_size: Vector2i) -> Vector2i:
	var screen_pos = DisplayServer.screen_get_position(screen_index)
	var screen_size = DisplayServer.screen_get_size(screen_index)
	
	var centered_pos = screen_pos + (screen_size / 2) - (window_size / 2)
	return centered_pos
	
# --resolution=
static func apply_commandline_args():
	var args = OS.get_cmdline_args()
	
	for arg in args:
		if arg.begins_with("--resolution="):
			_apply_window_resolution(arg)
				
		if arg == "--position=left" || arg == "--position=right":
			_apply_window_position(arg)
	
		if arg.begins_with("--volume-master="):
			_apply_volume_master(arg)
			

static func _apply_window_resolution(arg : String) -> void:
	var resolution
	var res_text = arg.replace("--resolution=", "")
	var parts = res_text.split("x")
	if parts.size() != 2:
		print("[MAIN ARGS ERROR] Resolution arg is wrong")
		return
	else:
		var width = int(parts[0])
		var height = int(parts[1])
		resolution = Vector2i(width, height)
		#print("Resolution set to: ", resolution)
		DisplayServer.window_set_size(resolution)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

static func _apply_window_position(arg : String) -> void:
	var screen_index = 0   
	var screen_pos = DisplayServer.screen_get_position(screen_index)
	var screen_size = DisplayServer.screen_get_size(screen_index)
	
	var resolution = DisplayServer.window_get_size()
	var center_window_position = screen_pos + (screen_size / 2) - (resolution / 2)	
	
	if arg == "--position=left":
		center_window_position.x -= resolution.x * 0.4
	if arg == "--position=right":
		center_window_position.x += resolution.x * 0.6
	
	#center_window_position.y = resolution.y * 0.05 # Desktop
	center_window_position.y = resolution.y * 0.4 # Laptop
	#print(center_window_position)
	DisplayServer.window_set_position(center_window_position)
		

static func _apply_volume_master(arg : String) -> void:
	var value = arg.replace("--volume-master=", "").to_float()
	AudioManager.set_master_volume(value)
