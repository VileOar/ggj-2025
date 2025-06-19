class_name Player
extends RigidBody2D

@export var player_index := 0

@onready var controller: PlayerFSM = %Controller

# GODOT MULTIPLAYER
func _enter_tree() -> void:
	if Global.multiplayer_status == 1:
		set_multiplayer_authority(name.to_int())

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	controller.integrate_forces(state)
