extends Control

@onready var menu_button: Button = %MenuButton
@onready var winner_sprite_p1: TextureRect = $WinnerSprite1
@onready var winner_sprite_p2: TextureRect = $WinnerSprite2

func _ready():
	menu_button.button_down.connect(_on_button_pressed)
	menu_button.mouse_entered.connect(_on_button_mouse_entered)

	set_winner(Global.winner_index != 1)

	AudioManager.play_audio(Global.Sounds.END_MUSIC)
	
	
func set_winner(is_p1_winner: bool) -> void:
	winner_sprite_p1.visible = is_p1_winner
	winner_sprite_p2.visible = !is_p1_winner
	

# Buttons Actions
func _on_button_pressed() -> void:
	AudioManager.play_audio(Global.Sounds.ACCEPT_UI)
	Global.change_scene(Global.Scenes.MAIN_MENU)

func _on_button_mouse_entered() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)
