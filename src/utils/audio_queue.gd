class_name AudioQueue
extends Node

@export var count : int

var _next_stream_id := 0

var _stream_players := []


# Called when the node enters the scene tree for the first time.
func _ready():
	var child = get_child(0)
	if child is AudioStreamPlayer2D:
		_stream_players.push_back(child)

		for i in count:
			var dup : AudioStreamPlayer2D = child.duplicate()
			add_child(dup)
			_stream_players.push_back(dup)


func play_sound():
	if !_stream_players[_next_stream_id].is_playing():
		_stream_players[_next_stream_id].play()
		_next_stream_id += 1
		_next_stream_id %= _stream_players.size()
