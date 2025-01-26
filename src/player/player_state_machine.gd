class_name PlayerFSM
extends StackStateMachine


@onready var _rigid_body := get_parent() as Player
@onready var _anim: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
	super._ready()
	push_state("WalkState")


func rigidbody() -> Player:
	return _rigid_body


## Called by the RigidBody's _integrate_forces method
func integrate_forces(ph_state: PhysicsDirectBodyState2D) -> void:
	current_state().integrate_forces(ph_state)


func _on_player_scene_body_entered(body: Node) -> void:
	current_state().on_collision(body)


func play_anim(anim_name) -> void:
	_anim.play(anim_name)
