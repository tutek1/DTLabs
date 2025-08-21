class_name GroundEnemyBH
extends CharacterBody3D

@export_category("Speeds")
@export var speed : float = 5.0
@export var up_speed : float = 10.0
@export var rotation_speed : float = 7

@export_category("Patrol")
@export var patrol_points : Array[Vector3]
@export var distance_threshold : float = 1

@export_category("Chase")
@export var chase_max_dist : float = 30
@export var update_time : float = 2
@export var enter_scale_up : float = 1.5
@export var enter_pos_up : float = 0.6
@export var enter_tween_time : float = 0.2

@export_category("Shooting")
@export var shoot_cooldown : float = 4
@export var shoot_wait : float = 0.5

# Refs
@onready var shoot_cast : RayCast3D = $ShootCast
@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D
@onready var blackboard : Blackboard = $Blackboard

enum BB_VAR 
{
	PATROL_POINT_IDX,
	IS_PLAYER_SEEN,
	PLAYER_NODE,
	ROTATE_MODE,
	LAST_ACTION
}

enum ROTATE_MODE 
{
	NONE,
	VELOCITY,
	HALF_VELOCITY_HALF_PLAYER,
	PLAYER,
}

enum ACTIONS 
{
	PATROL,
	CHASE
}

func _ready() -> void:
	blackboard.set_value(BB_VAR.IS_PLAYER_SEEN, false)
	blackboard.set_value(BB_VAR.PATROL_POINT_IDX, 0)
	blackboard.set_value(BB_VAR.PLAYER_NODE, null)
	blackboard.set_value(BB_VAR.ROTATE_MODE, ROTATE_MODE.VELOCITY)
	blackboard.set_value(BB_VAR.LAST_ACTION, ACTIONS.PATROL)

func _physics_process(delta : float) -> void:
	_gravity(delta)
	_movement(delta)
	_rotate_enemy(delta)
	
	move_and_slide()

# Handles falling
func _gravity(delta : float) -> void:
	if is_on_floor(): return
	
	velocity += get_gravity() * delta

# Handles movement of the player
func _movement(delta : float) -> void:
	var target : Vector3 = navigation_agent_3d.get_next_path_position()
	var distance_to_target : Vector3 = target - global_position

	# Avoid point oscillation
	if distance_to_target.length() < navigation_agent_3d.path_desired_distance:
		velocity.x = 0
		velocity.z = 0
		return

	var direction : Vector3 = target - global_position
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Used for the robot to fly up and down on navmesh links
	if distance_to_target.y > 0.5:
		velocity.y += direction.y * up_speed * delta
	elif distance_to_target.y < -0.5:
		velocity.y += -direction.y * up_speed/4 * delta

# Rotates the enemy based on direction and delta
func _rotate_enemy(delta: float) -> void:
	var direction : Vector3
	var player : PlayerController3D = blackboard.get_value(BB_VAR.PLAYER_NODE)
	
	# Player exists check
	var dir_to_player : Vector3
	if player != null:
		dir_to_player = player.global_position - global_position
	
	# Get the current direction based on mode
	match blackboard.get_value(BB_VAR.ROTATE_MODE):
		ROTATE_MODE.VELOCITY:
			direction = velocity
		ROTATE_MODE.HALF_VELOCITY_HALF_PLAYER:
			direction = dir_to_player * 0.5 + velocity * 0.5
		ROTATE_MODE.PLAYER:
			direction = dir_to_player
	
	# Should we rotate? To not oscilate quickly
	if Vector2(direction.x, direction.z).length() < 0.1: return
	var angle : float = atan2(direction.x, direction.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

func _on_vision_area_body_entered(body):
	if not (body is PlayerController3D): return
	blackboard.set_value(BB_VAR.PLAYER_NODE, body)
	blackboard.set_value(BB_VAR.IS_PLAYER_SEEN, true)
