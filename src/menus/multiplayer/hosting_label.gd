extends Node

var is_playing_animation : bool = false
var hosting_text : String = "hosting"
var counter : int = 0
var timer

func _ready() -> void:
	is_playing_animation = false
	self.text = ""
	timer = Timer.new()
	timer.wait_time = 0.7
	timer.one_shot = false
	timer.timeout.connect(_on_hosting_timeout)
	add_child(timer)
	timer.start()

func _on_hosting_timeout() -> void:
	if not is_playing_animation:
		return
		
	if counter == 0 || counter == 4:
		self.text = hosting_text 
		counter = 0
	else: 
		self.text += "."
		
	counter += 1
	
	
func start_hosting() -> void:
	is_playing_animation = true
	self.text = hosting_text
	counter = 0
	
func stop_hosting() -> void:
	is_playing_animation = false
	self.text = ""
	counter = 0
