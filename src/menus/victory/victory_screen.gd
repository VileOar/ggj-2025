extends Control

# Audio mixing values
const INIT_VOL := -40.0
const FINAL_VOL := -12.0
const FADE_TIMEOUT := 3.8
const FADE_DURATION := 1.0

@onready var menu_button: Button = %MenuButton
@onready var winner_sprite_p1: TextureRect = $WinnerSprite1
@onready var winner_sprite_p2: TextureRect = $WinnerSprite2
@onready var _ambiance_player: AudioStreamPlayer = %Ambiance


func _ready():
	menu_button.button_down.connect(_on_button_pressed)
	menu_button.mouse_entered.connect(_on_button_mouse_entered)

	set_winner(Global.winner_index != 1)

	_ambiance_player.play()
	AudioManager.play_audio(Global.Sounds.END_JINGLE)
	AudioManager.play_audio(Global.Sounds.END_MUSIC, INIT_VOL)

	await get_tree().create_timer(FADE_TIMEOUT).timeout
	AudioManager.fade_audio(Global.Sounds.END_MUSIC, FADE_DURATION, FINAL_VOL)


func set_winner(is_p1_winner: bool) -> void:
	winner_sprite_p1.visible = is_p1_winner
	winner_sprite_p2.visible = !is_p1_winner


# Buttons Actions
func _on_button_pressed() -> void:
	AudioManager.stop_audio(Global.Sounds.END_MUSIC)
	AudioManager.stop_audio(Global.Sounds.END_JINGLE)
	_ambiance_player.stop()

	AudioManager.play_audio(Global.Sounds.ACCEPT_UI)
	Global.change_scene(Global.Scenes.MAIN_MENU)


func _on_button_mouse_entered() -> void:
	AudioManager.play_audio(Global.Sounds.HOVER_UI)
