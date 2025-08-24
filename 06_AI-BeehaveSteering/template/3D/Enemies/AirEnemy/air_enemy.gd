class_name AirEnemy
extends CharacterBody3D

@export_category("Speeds")
@export var fly_speed : float = 5.0
@export var fly_acceleration : float = 10.0
@export var rotation_speed : float = 4
@export var up_down_rot_mult : float = 2

@export_category("Behavior")
@export var contact_damage : float = 5
@export var damage_cooldown : float = 0.5
@export var max_player_chase_dist : float = 20 

@export_category("Sterring")
@export var draw_debug : bool = true
@export var steerings : Array[SteeringBehavior]

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var _player : PlayerController3D
var _target : Vector3 = Vector3(0, -0.1, 0)
var _last_damage_time : float = 0


func _physics_process(delta : float) -> void:
	_behavior()
	_steering(delta)
	_rotate_enemy(delta)
	_check_collisions()
	
	move_and_slide()

# Basic stay in place behavior until player is seen for now
func _behavior() -> void:
	if _player != null:
		_target = _player.global_position
		if _player.global_position.distance_to(global_position) > max_player_chase_dist:
			_player = null
	else:
		_target = Vector3(25, 5, 10)

# Handles the steering forces of the enemy
func _steering(delta : float) -> void:
	
	# TODO Accumulate all forces from all steerings
	var force : Vector3
	
	
	# Normalize only when a lot of forces act 
	# -> preserves force magnitude for arrival and others
	if force.length() > 1.0:
		force = force.normalized()
	velocity += force * fly_acceleration * delta
	
	# Max speed check
	if velocity.length() > fly_speed:
		velocity = velocity.normalized() * fly_speed
	
	# Draw debug velocity if turned on
	if draw_debug:
		DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.GREEN, 0.1)

# Rotates the enemy based on direction and delta
func _rotate_enemy(delta: float) -> void:
	# Get the direction normalized
	var direction : Vector3 = velocity.normalized()
	direction.x *= up_down_rot_mult
	direction.z *= up_down_rot_mult
	
	# Stop rotating when slow enough -> prevents oscilation
	if direction.length() < 0.1:
		return
	
	# Rotate a bit towards a natural direction (why? it looks better in game)
	rotation.x = lerp_angle(rotation.x, 0, rotation_speed * delta)
	rotation.z = lerp_angle(rotation.z, 0, rotation_speed * delta)
	
	# Use the looking_at to transform the enemy to look at the target
	var target_transform : Transform3D = transform\
		.looking_at(transform.origin + direction, Vector3.UP)
	
	# Interpolate between current basis and target basis for smooth rotation
	transform.basis = transform.basis.slerp(target_transform.basis, rotation_speed * delta)

# Check all current collisions and if it is a player damage them
func _check_collisions() -> void:
	if _last_damage_time + damage_cooldown * 1000 > Time.get_ticks_msec(): return 
	
	for idx in range(0, get_slide_collision_count()):
		var collision : KinematicCollision3D = get_slide_collision(idx)
		var collider : Object = collision.get_collider()
		if collider is PlayerController3D:
			collider.receive_damage(contact_damage, self)
			_last_damage_time = Time.get_ticks_msec()
			return

# Returns the current target position
func get_target() -> Vector3:
	return _target

# Returns the player ref
func get_player() -> PlayerController3D:
	return _player

# See the player
func _on_vision_area_body_entered(body : Node3D) -> void:
	if body is PlayerController3D:
		_player = body
