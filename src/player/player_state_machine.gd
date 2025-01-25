class_name PlayerFSM
extends StackStateMachine


@onready var _rigid_body := get_parent() as RigidBody2D


func _ready() -> void:
	super._ready()
	push_state("WalkState")


func rigidbody() -> RigidBody2D:
	return _rigid_body
