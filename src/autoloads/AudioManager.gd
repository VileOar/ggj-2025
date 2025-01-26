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
	add_to_sound_player_dictionary("ButtonAccept", $UI/ButtonAccept)
	add_to_sound_player_dictionary("ButtonDecline", $UI/ButtonDecline)
	
	# Buble
	add_to_sound_player_dictionary("Bounce", $Bubble/Bounce)
	add_to_sound_player_dictionary("Charge", $Bubble/Charge)
	add_to_sound_player_dictionary("Merge", $Bubble/Merge)
	add_to_sound_player_dictionary("Pop", $Bubble/Pop)

	# Crab
	add_to_sound_player_dictionary("Death", $Crab/Death)	
	add_to_sound_player_dictionary("Flailing", $Crab/Flailing)	
	add_to_sound_player_dictionary("Taunt", $Crab/Taunt)	
	add_to_sound_player_dictionary("Walk", $Crab/Walk)	
	add_to_sound_player_dictionary("FinalImpact", $Crab/FinalImpact)	
	add_to_sound_player_dictionary("ShootBig", $Crab/ShootBig)	
	add_to_sound_player_dictionary("ShootSmall", $Crab/ShootSmall)	
	
	# Music
	add_to_sound_player_dictionary("EndRound", $Music/EndRound)
	add_to_sound_player_dictionary("Ambiance", $Music/Ambiance)
	add_to_sound_player_dictionary("EndGamee", $Music/EndGame)
	add_to_sound_player_dictionary("Arena", $Music/Arena)
	add_to_sound_player_dictionary("Menu", $Music/Menu)
	
	
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
