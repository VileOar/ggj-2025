extends Control

@export var address : String = "127.0.0.1"
@export var port : int = 8910

@export var player_scene : PackedScene

#@onready var game_scene : PackedScene = preload("res://src/main_scenes/mp_stage.tscn")
@onready var hosting_indicator: Label = %HostingIndicator
@onready var player_1: AnimatedSprite2D = %Player1
@onready var player_2: AnimatedSprite2D = %Player2
@onready var start_game_button: Button = %StartGameButton
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var back_button: Button = %BackButton

@onready var ip_text_edit: LineEdit = %IPTextEdit
@onready var port_text_edit: LineEdit = %PortTextEdit

@onready var multiplayer_logic: Node2D = %MultiplayerLogic


func _ready() -> void:
	
	# Multiplalyer signals connection
	multiplayer_logic.update_connected_players.connect(update_client_ui_information)
	multiplayer_logic.updates_player_id_status.connect(update_player_status)
	
	start_game_button.hide()
	join_button.show()
	
	# Connects button to hear sound on mouse entered
	host_button.mouse_entered.connect(_on_mouse_entered)
	start_game_button.mouse_entered.connect(_on_mouse_entered)
	join_button.mouse_entered.connect(_on_mouse_entered)
	back_button.mouse_entered.connect(_on_mouse_entered)


func _update_adress_and_port():
	address = ip_text_edit.text
	port = int(port_text_edit.text)
	#print("IP: ", address, ":", port)


#region ButtonCalls
func _on_host_button_pressed():
	_update_adress_and_port()
	var result = multiplayer_logic.try_host_server(address, port)
	print("Host result = ", result)
	if result == OK:
		_start_hosting()
	else:
		AudioManager.play_decline_sfx()



func _on_join_button_pressed() -> void:
	_update_adress_and_port()
	var _result = multiplayer_logic.try_join_client_to_server(address, port)
	
	
func _on_start_game_button_pressed() -> void:
	if multiplayer_logic.try_start_game() == false:
		AudioManager.play_decline_sfx()
		print("[Client Error] Not Enough Players")
		# TODO Display error message in UI
	else:
		print("Starting Game on Host.")
	
	
func _on_back_button_pressed() -> void:
	hide()
	_stop_hosting()
	_reset_client_ui_information()
	get_parent().get_parent().start_menu_container.show()
	
#endregion

#region UpdateUIInformationOnActions

func _start_hosting() -> void:
	print("Waiting for players!")
	hosting_indicator.start_hosting()
	player_1.show()
	start_game_button.show()
	start_game_button.disabled = false
	join_button.hide()
	multiplayer_logic.start_hosting()


func _stop_hosting() -> void:
	hosting_indicator.stop_hosting()
	player_1.hide()
	start_game_button.hide()
	start_game_button.disabled = true
	join_button.show()
	multiplayer_logic.stop_hosting()


func update_client_ui_information() -> void:
	if MpGameManager.mp_players.has(1):
		player_1.show()
	if MpGameManager.mp_players.size() > 1:
		player_2.show()
	host_button.disabled = true
	start_game_button.disabled = true


func _reset_client_ui_information() -> void:
	player_1.hide()
	player_2.hide()
	host_button.disabled = false
	start_game_button.visible = false

func update_player_status(player_id : int, is_player_visible : bool) -> void:
	if player_id == MpGameManager.HOST_ID:
		player_1.visible = is_player_visible
	elif player_id == MpGameManager.SECOND_PLAYER:
		player_2.visible = is_player_visible
		
#endregion


func _on_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
