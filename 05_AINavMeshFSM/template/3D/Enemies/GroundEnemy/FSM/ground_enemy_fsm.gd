class_name GroundEnemyFSM
extends CharacterBody3D

@export var speed : float = 5.0
@export var up_speed : float = 25.0
@export var rotation_speed : float = 7

var _player : PlayerController3D = null

func _physics_process(delta : float) -> void:
	_gravity(delta)
	_movement(delta)
	rotate_enemy(delta, velocity)
	
	move_and_slide()

# Handles falling
func _gravity(delta : float) -> void:
	if is_on_floor(): return
	
	velocity += get_gravity() * delta

# Handles movement of the player
func _movement(delta : float) -> void:
	# TEMPORARY until navmesh setup
	var target_pos : Vector3 = global_position + Vector3.FORWARD
	var distance_to_target : Vector3 = target_pos - global_position
	
	var direction : Vector3 = distance_to_target.normalized()
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Used for the robot to fly up and down on navmesh links
	if distance_to_target.y > 0.5:
		velocity.y += direction.y * up_speed * delta
	elif distance_to_target.y < -0.5:
		velocity.y += -direction.y * up_speed/4 * delta

# Rotates the enemy based on direction and delta
func rotate_enemy(delta: float, direction : Vector3) -> void:
	if Vector2(direction.x, direction.z).length() < 0.1: return
	var angle : float = atan2(direction.x, direction.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

# DEBUG function to test out the navmesh
func _input(event : InputEvent):
	if event is InputEventMouseButton:
		
		# Get mouse and create raycast ray
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var ray_origin : Vector3 = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
		var ray_direction : Vector3 = get_viewport().get_camera_3d().project_ray_normal(mouse_pos)
		var ray_end = ray_origin + ray_direction * 1000.0
		
		# Query the physics server if we collided
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result : Dictionary = space_state.intersect_ray(query)
		
		if result:
			# TODO go there
			pass


func get_player() -> PlayerController3D:
	return _player
