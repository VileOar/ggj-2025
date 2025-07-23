extends Node

const BUBBLE_GROUP_NAME = "Bubble"

# Returns a vector2 windows position in the middle of the main screen
func get_new_window_position(new_resolution: Vector2) -> Vector2i:
	#var base_size: Vector2 = Vector2(1920, 1080)
	var window_size: Vector2 = DisplayServer.screen_get_size()
	print(window_size)
	# TODO, esta logica não faz sentido, ver se é importante mais tarde aka nunca
	#var scale: float = min(new_resolution.x / base_size.x, window_size.y / base_size.y)
	#var scaled_size: Vector2 = (base_size * scale)
	var scaled_size: Vector2 = new_resolution

	var window_x: float = (window_size.x / 2) - (scaled_size.x / 2)
	var window_y:float = (window_size.y / 2) - (scaled_size.y / 2)

	#return Vector2(window_x, window_y)
	return Vector2i(int(window_x), int(window_y))
	
func center_window_on_screen(screen_index: int, window_size: Vector2i):
	var screen_pos = DisplayServer.screen_get_position(screen_index)
	var screen_size = DisplayServer.screen_get_size(screen_index)
	
	var centered_pos = screen_pos + (screen_size / 2) - (window_size / 2)
	DisplayServer.window_set_position(centered_pos)
	
func apply_commandline_args():
	var args = OS.get_cmdline_args()
	var resolution := Vector2i(1280, 720) 
	var center_window_position := Vector2i(100, 100)    	
	
	for arg in args:
		if arg.begins_with("--resolution="):
			var res_text = arg.replace("--resolution=", "")
			var parts = res_text.split("x")
			if parts.size() == 2:
				var width = int(parts[0])
				var height = int(parts[1])
				resolution = Vector2i(width, height)
				print("Resolution set to: ", resolution)
				
		if arg == "--position=left":
			center_window_position = Utils.get_new_window_position(resolution)
			center_window_position.x -= resolution.x - 950
		if arg == "--position=right":
			center_window_position = Utils.get_new_window_position(resolution)
			center_window_position.x += resolution.x + 950
	
		if arg.begins_with("--volume-master="):
			var value = arg.replace("--volume-master=", "").to_float()
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_position(center_window_position)
	center_window_on_screen(0, center_window_position)
	
# Returns the top-left position to center a window with the given resolution
#func get_new_window_position(new_resolution: Vector2i) -> Vector2i:
	#var screen_size: Vector2i = DisplayServer.screen_get_size()
	#var centered_x: int = (screen_size.x - new_resolution.x) / 2
	#var centered_y: int = (screen_size.y - new_resolution.y) / 2
	#return Vector2i(centered_x, centered_y)
