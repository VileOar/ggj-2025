extends Node2D

# Reference to the itself, ensuring only one exists
var instance : Node

# Dictionary to store each SoundPlayer nodes by its name
var _sound_player_by_name : Dictionary = {}
var queues_by_name : Dictionary = {}

var shoot_is_cooldown = false
var bounce_is_cooldown = false

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

	queues_by_name["shoot"] = $ShootAudioQueue
	queues_by_name["bounce"] = $BounceAudioQueue
	
	
func play_audio(audio_name):
	# Get the "audio_name" node if it exists and is an AudioStreamPlayer
	var audio_node = _sound_player_by_name.get(audio_name)
	if audio_node != null:
			audio_node.play()


func play_audio_queue(audio_name):
	var audio_queue : AudioQueue = queues_by_name.get(audio_name)	
	if audio_queue != null:
			audio_queue.play_sound()


func play_shoot_delay(delay:float):
	if !shoot_is_cooldown:
		shoot_is_cooldown = true
		var audio_queue : AudioQueue = queues_by_name.get("shoot")	
		if audio_queue != null:
			audio_queue.play_sound()
			await get_tree().create_timer(delay).timeout
			shoot_is_cooldown = false


func play_bounce_delay(delay:float):
	if !bounce_is_cooldown:
		bounce_is_cooldown = true
		var audio_queue : AudioQueue = queues_by_name.get("bounce")	
		if audio_queue != null:
			audio_queue.play_sound()
			await get_tree().create_timer(delay).timeout
			bounce_is_cooldown = false


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
