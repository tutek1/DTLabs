extends CharacterBody3D

@export var speed : float = 5
@export var rotation_speed : float = 4
@export var gravity : float = -9.81
@export var jump_force : float = 10

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	pass

func _physics_process(delta : float) -> void:
	_movement()
	_rotate_player(delta)
	_apply_gravity(delta)
	_jump()
	
	move_and_slide()

# Handles the horizontal movement of the player
func _movement() -> void:
	var x_axis : float = Input.get_axis("left", "right")
	var z_axis : float = Input.get_axis("backward", "forward")
	
	# Create a direction vector in the world coords and transforms it into player local coords
	var direction : Vector3 = Vector3(x_axis, 0, -z_axis)
	direction = basis * direction
	direction = direction.normalized()
	
	# Set the new velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

# Rotates the player based on the direction they are moving on the Y-axis
func _rotate_player(delta : float) -> void:
	if abs(velocity.x) < 0.01 and abs(velocity.z) < 0.01: return
	var angle : float = atan2(velocity.x, velocity.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

# Applies the gravity to the player
func _apply_gravity(delta : float) -> void:
	velocity.y += gravity * delta

# Checks if the player can and wants to jump. If yes the apply instant force
func _jump() -> void:
	if not Input.is_action_just_pressed("jump"): return
	if not is_on_floor(): return
	
	velocity.y = jump_force
