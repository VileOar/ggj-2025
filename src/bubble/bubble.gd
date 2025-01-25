extends RigidBody2D


const SPEED = 300.0
const SPEED_STOP_THRESHOLD = 5

const DRAG_RESISTANCE = 0.9999
const ON_COLLISION_DIRECTION_VARIATION = 0.25

var velocity
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	# To detect collisions between objects
	set_contact_monitor(true)
	max_contacts_reported = 5
	
	# applies random spawn direction
	_apply_random_start_direction()
	
	# apply velocity	
	#velocity = Vector2(SPEED * x_direction, - SPEED * y_direction)


## TEMP, DELETE
func _apply_random_start_direction() -> void: 
	var x_direction = rng.randf_range(-1, 1)
	var y_direction = rng.randf_range(-1, 1)
	velocity = Vector2(SPEED * x_direction, - SPEED * y_direction)


func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	_apply_drag()
	
	# ON collision detection, changes direction with slight variable 
	if collision_info:
		_change_direction_slighly(collision_info)
		
	
func _apply_drag() -> void:
#	stop speed after threshold
	if abs(velocity.x) < SPEED_STOP_THRESHOLD && abs(velocity.y) < SPEED_STOP_THRESHOLD:
		velocity.x = 0
		velocity.y = 0
	else:
#		apply drag normally
		velocity.x *= DRAG_RESISTANCE
		velocity.y *= DRAG_RESISTANCE
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var velocity := state.get_linear_velocity()
		
	for collider_index in state.get_contact_count():
		var collider := state.get_contact_collider_object(collider_index)
		var collision_normal := state.get_contact_local_normal(collider_index)
	

func _change_direction_slighly(collision_info) -> void:
	var new_bounce_vector = collision_info.get_normal()
	new_bounce_vector.x += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	new_bounce_vector.y += rng.randf_range(-ON_COLLISION_DIRECTION_VARIATION, ON_COLLISION_DIRECTION_VARIATION)
	velocity = velocity.bounce(new_bounce_vector.normalized())

#	TODO work
func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	#velocity.x *= 0.5
	#velocity.y *= 0.5
