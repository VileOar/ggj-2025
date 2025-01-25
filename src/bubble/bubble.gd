extends RigidBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const RESISTANCE = 0.9

var velocity
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	var x_direction = rng.randf_range(-1, 1)
	var y_direction = rng.randf_range(-1, 1)
	velocity = Vector2(SPEED * x_direction, - SPEED * y_direction)
	contact_monitor = true


func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		velocity.x *= RESISTANCE
		velocity.y *= RESISTANCE
		#if velocity.bounce() == true:
			#print("bounce") 
	
	for collider_index in get_contact_count():
		#var collider := get_contact_collider_object(collider_index)
		print(collider_index)
	
	#for i in get_contact_count():
		#var c = get_colliding_bodies()
	
	
	
func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	
	
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
