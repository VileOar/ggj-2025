extends PanelContainer

#@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_1_ani_1: AnimatedSprite2D = %Player1Ani1
@onready var player_1_ani_2: AnimatedSprite2D = %Player1Ani2Walk
@onready var player_1_ani_3: AnimatedSprite2D = %Player1Ani3Float
@onready var player_2_ani_1: AnimatedSprite2D = %Player2Ani1
@onready var player_2_ani_2: AnimatedSprite2D = %Player2Ani2
@onready var player_2_ani_3: AnimatedSprite2D = %Player2Ani3Walk
@onready var player_2_ani_4: AnimatedSprite2D = %Player2Ani4

#var path_follow_speed = 0.1

func _ready() -> void:
	animation_player.play("Animation")
	player_1_ani_1.play("taunt")
	player_1_ani_2.play("walk")
	player_1_ani_3.play("float")
	player_2_ani_1.play("dead")
	player_2_ani_2.play("charge")
	player_2_ani_3.play("walk")
	player_2_ani_4.play("taunt")
	
#func _physics_process(delta: float) -> void:
	#path_follow_2d.progress_ratio += delta * path_follow_speed
	
	
func player1_taunt():
		player_1_ani_2.play("taunt")

func player1_stop_taunt():
		player_1_ani_2.play("walk")
		
func player2_taunt():
		player_2_ani_3.play("taunt")

func player2_stop_taunt():
		player_2_ani_3.play("walk")
