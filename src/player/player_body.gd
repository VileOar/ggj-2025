class_name Player
extends RigidBody2D


@onready var controller: PlayerFSM = %Controller


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	controller.integrate_forces(state)
