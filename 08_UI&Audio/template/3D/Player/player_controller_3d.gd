class_name PlayerController3D
extends CharacterBody3D

@export var camera_pivot : PlayerCamera3D
@export var stats : PlayerStats

@export_group("Movement")
@export var acceleration : float = 75
@export var dampening : float = 10
@export var rotation_speed : float = 8

@export_group("Physics")
@export var player_mass : float = 20
@export var gravity : float = -29.43

@export_group("Animation")
@export var walk_mult : float = 2
@export var fall_mult : float = 0.075
@export var jump_mult : float = 0.1
@export var gun_IK_offset : float = 1.3
@export var gun_point_depth : float = 15
@export var gun_point_offset : Vector3 = Vector3(0, 4, 0)

@onready var animation_tree : AnimationTree = $Mesh/AnimationTree
@onready var look_at_modifier_3d : LookAtModifier3D = $Mesh/Armature/Skeleton3D/LookAtModifier3D
@onready var gun_target : Node3D = $GunTarget
@onready var shoot_point : Node3D = $Mesh/Armature/Skeleton3D/BoneAttachment3D2/ShootPoint
@onready var shoot_cooldown : Timer = $ShootCooldown

const ENEMY_LAYER = 4

var _has_double_jumped : bool = false
var _do_movement : bool = true
var _can_be_damaged : bool = true
var _interact_node_in_area : Node3D
var _controllable : bool = true
var _current_hp : float
var _connected : bool

func _ready() -> void:
	_current_hp = stats.health

func _physics_process(delta : float) -> void:
	_movement(delta)
	_rotate_player(delta)
	_apply_gravity(delta)
	_jump()
	_double_jump()
	_interact()
	_update_gun_target()
	_shoot()
	
	_check_collisions(delta)
	move_and_slide()
	
	_animation_tree_update()


# Handles the horizontal movement of the player
func _movement(delta : float) -> void:
	if not _do_movement: return
	if not _controllable: return
	
	var x_axis : float = Input.get_axis("left", "right")
	var z_axis : float = Input.get_axis("backward", "forward")
	
	# Create a direction vector in the world coords and transforms it into player local coords
	var direction : Vector3 = Vector3(x_axis, 0, -z_axis)
	direction = camera_pivot.basis * direction
	direction.y = 0
	direction = direction.normalized()
	
	# Add the new velocity
	velocity.x += direction.x * delta * acceleration
	velocity.z += direction.z * delta * acceleration
	
	# Clamp max speed
	var horizontal_velocity : Vector3 = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() > stats.speed:
		horizontal_velocity = horizontal_velocity.normalized() * stats.speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
	# Dampening if not moving
	if abs(z_axis) < 0.01 and abs(x_axis) < 0.01:
		var damp_coef : float = 1 - dampening * delta
		damp_coef = clamp(damp_coef, 0, 1)
		
		velocity.x *= damp_coef
		velocity.z *= damp_coef

# Rotates the player based on the direction they are moving on the Y-axis
func _rotate_player(delta : float) -> void:
	if not _controllable: return
	if Vector2(velocity.x, velocity.z).length() < 0.1: return
	var direction : Vector3 = -camera_pivot.basis.z
	var angle : float = atan2(direction.x, direction.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

# Applies the gravity to the player
func _apply_gravity(delta : float) -> void:
	velocity.y += gravity * delta

# Checks if the player can and wants to jump. If yes the apply instant force
func _jump() -> void:
	if not _controllable: return
	if not Input.is_action_just_pressed("jump"): return
	if not is_on_floor(): return
	
	velocity.y = stats.jump_force

# Handles the double jump of the player, conditions, reset, and apply
func _double_jump() -> void:
	if not stats.has_double_jump: return
	if not _controllable: return
	
	# Double jump reset when on ground
	if is_on_floor():
		_has_double_jumped = false
		return
	
	# Conditions
	if _has_double_jumped: return
	if not Input.is_action_just_pressed("jump"): return
	
	# Jump
	_has_double_jumped = true
	velocity.y = stats.jump_force

# Interacts with node in the interact area 3D
func _interact() -> void:
	if not Input.is_action_just_pressed("interact"): return
	if _interact_node_in_area == null: return
	
	_interact_node_in_area.interact(self)

# Updates the target for the gun LookAt modifier
func _update_gun_target() -> void:
	var camera_pos : Vector3 = camera_pivot.camera_3d.global_position
	var pivot_pos : Vector3 = camera_pivot.global_position
	var cam_to_pivot : Vector3 = (pivot_pos - camera_pos).normalized()
	
	# Change the influence based on angle
	var angle_to_player : float = basis.z.angle_to(cam_to_pivot)
	var influence : float = lerp(0, 1, clamp(angle_to_player - gun_IK_offset, 0, 1))
	look_at_modifier_3d.influence = influence
	
	# Pivot position + offset + inverse direction to camera 
	gun_target.global_position = pivot_pos + gun_point_offset + cam_to_pivot * gun_point_depth

# Shoots a projectile when conditions are met
func _shoot() -> void:
	if not shoot_cooldown.time_left <= 0: return
	if not Input.is_action_just_pressed("shoot"): return
	shoot_cooldown.start(stats.shoot_cooldown)
	
	# Create projectile
	var projectile : PlayerProjectile = stats.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	# Set position, rotation, damage
	projectile.global_position =  shoot_point.global_position
	projectile.global_rotation = shoot_point.global_rotation
	projectile.set_damage(stats.projectile_damage)
	
	# Set velocity
	var direction : Vector3 = (gun_target.global_position - projectile.global_position).normalized()
	projectile.set_velocity(direction * stats.projectile_speed)

# Process collisions with rigidbodies
func _check_collisions(delta : float) -> void:
	for i in get_slide_collision_count():
		var collision : KinematicCollision3D = get_slide_collision(i)
		var collider : Object = collision.get_collider()
		if collider is RigidBody3D:
			
			# Calculate the force
			var push_direction : Vector3 = -collision.get_normal()
			var force : Vector3 = push_direction * (player_mass / collider.mass)
			
			# Get the offset from collision point to rigidbody center
			var pos_offset : Vector3 = collision.get_position() - collider.global_position
			
			# Apply the force
			collider.apply_impulse(force * delta, pos_offset)

# Updates the parameters of the animation tree
func _animation_tree_update() -> void:
	# Blend amount Fall
	var fall_coef : float = 0 
	if velocity.y < 0:
		fall_coef = clamp(-velocity.y * fall_mult, 0.0, 1.0) 
	animation_tree.set("parameters/FreeMoveBlendTree/FallBlend/blend_amount", fall_coef)
	
	# Blend amount Jump
	var jump_coef : float = 0 
	if abs(velocity.y) > 0:
		jump_coef = clamp(abs(velocity.y) * jump_mult, 0.0, 1.0) 
	animation_tree.set("parameters/FreeMoveBlendTree/JumpBlend/blend_amount", jump_coef)
	
	# Blend amount Walk
	var local_velocity : Vector3 = velocity * basis
	local_velocity.y = 0
	animation_tree.set("parameters/FreeMoveBlendTree/WalkBlend/blend_amount", (local_velocity.length() / stats.speed))
	
	# BlendSpace2D walking
	var vel2 : Vector2 = Vector2(local_velocity.x, -local_velocity.z).normalized()
	animation_tree.set("parameters/FreeMoveBlendTree/WalkSpace2D/blend_position", vel2)
	
	# BlendSpace2D walking timescale
	var walkscale : float = (local_velocity.length() / stats.speed) * walk_mult
	animation_tree["parameters/FreeMoveBlendTree/TimeScale/scale"] = walkscale

# TODO Fill out during codelab
func collectible_touched(collectible : Collectible) -> void:
	pass

# Sets a control variable if the _movement() function should be run or not
func set_do_movement(value : bool, delay : float = 0) -> void:
	if delay == 0:
		_do_movement = value
		return
	
	await get_tree().create_timer(delay).timeout
	_do_movement = value

func receive_damage(value : float, from : Node3D):
	if not _can_be_damaged: return
	_can_be_damaged = false
	
	_current_hp -= value
	if _current_hp <= 0:
		_current_hp = 0
		print("Player dead")
	
	print("Player hit! hp: " + str(_current_hp))
	
	# Restrict movement for a while
	_do_movement = false
	set_do_movement(true, stats.knockback_time)
	
	# Knockback the player
	var dir_to_player : Vector3 = (global_position - from.global_position).normalized()
	dir_to_player.x *= stats.knockback_force.x
	dir_to_player.z *= stats.knockback_force.x
	dir_to_player.y = stats.knockback_force.y
	velocity = dir_to_player
	
	# Do not collide with enemies for invincibility time
	collision_mask -= ENEMY_LAYER
	await get_tree().create_timer(stats.invincivility_time).timeout
	collision_mask += ENEMY_LAYER
	_can_be_damaged = true

func set_connect_anim_bool(value : bool) -> void:
	_connected = value

# Call to set if the player can be controlled
func set_controllable(value : bool) -> void:
	_controllable = value
	velocity = Vector3.ZERO

func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Interactable"):
		print(body.name + " entered interact area")
		_interact_node_in_area = body

func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Interactable"):
		print(body.name + " exitted interact area")
		_interact_node_in_area = null
