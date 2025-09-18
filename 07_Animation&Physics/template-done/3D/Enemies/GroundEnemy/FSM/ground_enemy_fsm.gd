class_name GroundEnemyFSM
extends CharacterBody3D

@export var health : float = 20.0
@export var speed : float = 5.0
@export var up_speed : float = 25.0
@export var rotation_speed : float = 7

@export var patrol_state : PatrolState
@export var chase_state : ChaseState
@export var shoot_state : ShootState

@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D
@onready var shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var shoot_cast : RayCast3D = $ShootCast

var _player : PlayerController3D = null
var _trigger_player_seen : bool = false
var _curr_state : AbstractFSMState
var _can_shoot : bool = true

func _ready():
	_switch_state(patrol_state)

func _physics_process(delta : float) -> void:
	_gravity(delta)
	_movement(delta)
	
	_curr_state.state_physics_process(self, delta)
	_check_transitions()
	
	move_and_slide()

# Handles falling
func _gravity(delta : float) -> void:
	if is_on_floor(): return
	
	velocity += get_gravity() * delta

# Handles movement of the player
func _movement(delta : float) -> void:
	var target_pos : Vector3 = navigation_agent_3d.get_next_path_position()
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

# Checks all possible transitions from the current state
func _check_transitions() -> void:
	match _curr_state:
		patrol_state:
			if _trans_patrol_to_chase():
				_switch_state(chase_state)
		chase_state:
			if _trans_chase_to_patrol():
				_switch_state(patrol_state)
			if _trans_chase_to_shoot():
				_switch_state(shoot_state)
		shoot_state:
			if _trans_shoot_to_chase():
				_switch_state(chase_state)
	
	# Reset triggers
	_trigger_player_seen = false

# Checks if we have started seeing the player this frame
func _trans_patrol_to_chase() -> bool:
	return _trigger_player_seen

# Checks if the player is too far away from the enemy
func _trans_chase_to_patrol() -> bool:
	var dist_to_player : float = _player.global_position.distance_to(global_position)
	if dist_to_player > chase_state.chase_max_dist:
		return true
	
	return false

# Checks we can shoot the player
func _trans_chase_to_shoot() -> bool:
	if _player == null: return false
	if not _can_shoot: return false
	
	shoot_cast.enabled = true
	shoot_cast.target_position = shoot_cast.to_local(_player.global_position)
	shoot_cast.force_raycast_update()
	shoot_cast.enabled = false
	
	if shoot_cast.get_collider() is PlayerController3D:
		return true
	
	return false

# Checks we can go back to chase from shooting the player
func _trans_shoot_to_chase() -> bool:
	return not _can_shoot

# Switches the private variable of current state to a new one
# Calls the appropriate state enter and exit functions
func _switch_state(new_state : AbstractFSMState) -> void:
	if new_state == _curr_state: return
	
	if _curr_state != null: _curr_state.state_exit(self)
	_curr_state = new_state
	_curr_state.state_enter(self)

# Rotates the enemy based on direction and delta
func rotate_enemy(delta: float, direction : Vector3) -> void:
	if Vector2(direction.x, direction.z).length() < 0.1: return
	var angle : float = atan2(direction.x, direction.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

# DEBUG function to test out the navmesh
#func _input(event : InputEvent):
	#if event is InputEventMouseButton:
		#
		## Get mouse and create raycast ray
		#var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		#var ray_origin : Vector3 = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
		#var ray_direction : Vector3 = get_viewport().get_camera_3d().project_ray_normal(mouse_pos)
		#var ray_end = ray_origin + ray_direction * 1000.0
		#
		## Query the physics server if we collided
		#var space_state = get_world_3d().direct_space_state
		#var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		#var result : Dictionary = space_state.intersect_ray(query)
		#
		#if result:
			#navigation_agent_3d.target_position = result.position

# Damagable Group function
func damage(value : float, node : Node3D) -> void:
	health -= value
	if health < 0:
		queue_free()
		return
	
	print("hit by " + node.name)

func get_player() -> PlayerController3D:
	return _player

func set_can_shoot(value : bool) -> void:
	_can_shoot = value

func _on_vision_area_body_entered(body : Node3D):
	if not body is PlayerController3D: return
	
	_player = body
	_trigger_player_seen = true

func _on_shoot_cooldown_timer_timeout():
	set_can_shoot(true)
