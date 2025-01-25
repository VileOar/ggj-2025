extends Node2D

# Dictionary to store each SoundPlayer nodes by its name
var _sound_player_by_name : Dictionary = {}

# Reference to the itself, ensuring only one exists
var instance : Node

func _ready():
	# Store itself to be avaiable in instance. this is used to call functions
	# of the script
	instance = self
	#add the sounds
	add_to_sound_player_dictionary("ButtonHover", $UI/ButtonHover)
	add_to_sound_player_dictionary("ButtonPress", $UI/ButtonPress)
	
	# Buble
	add_to_sound_player_dictionary("Pop", $Bubble/Pop)

	# Player
	add_to_sound_player_dictionary("Charge", $Player/Charge)	
	
	#Music
	add_to_sound_player_dictionary("Music1", $Music/Music1)
	
	
func play_audio(audio_name):
	# Get the "audio_name" node if it exists and is an AudioStreamPlayer
	var audio_node = _sound_player_by_name.get(audio_name)
	if audio_name == "ButtonHover":
		audio_node.pitch_scale = randf_range(0.98,1.02)
	else:
		audio_node.pitch_scale = randf_range(0.9,1.1)
	
	if audio_node != null:
			audio_node.play()


func stop_audio(audio_name):
	var audio_node = _sound_player_by_name.get(audio_name)
	if audio_node != null:
		audio_node.stop()


func play_audio_Restricted(audio_name):
# Get the "audio_name" node if it exists and is an AudioStreamPlayer
	var audio_node = _sound_player_by_name.get(audio_name)
	
	if audio_node != null:
		# If audio_node exists and is not playing already, play audio
		if !audio_node.is_playing():
			audio_node.play()


func add_to_sound_player_dictionary(node_name, node):
	# Add the node to the sound player dictionary
	# This works as a list with a name to each sound, so you can get it later
	_sound_player_by_name[node_name] = node
