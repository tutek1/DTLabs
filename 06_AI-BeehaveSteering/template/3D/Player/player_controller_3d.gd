class_name PlayerController3D
extends CharacterBody3D

@export var camera_pivot : PlayerCamera3D

@export_category("Horizontal")
@export var speed : float = 7
@export var acceleration : float = 75
@export var dampening : float = 10

@export_category("Vertical")
@export var rotation_speed : float = 8
@export var gravity : float = -9.81
@export var jump_force : float = 10

@export_category("Enemies")
@export var knockback_force : Vector2 = Vector2(6, 7)
@export var knockback_time : float = 0.75

var _has_double_jumped : bool = false
var _do_movement : bool = true

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	pass

func _physics_process(delta : float) -> void:
	_movement(delta)
	_rotate_player(delta)
	_apply_gravity(delta)
	_jump()
	_double_jump()
	
	move_and_slide()

# Handles the horizontal movement of the player
func _movement(delta : float) -> void:
	if not _do_movement: return
	
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
	if horizontal_velocity.length() > speed:
		horizontal_velocity = horizontal_velocity.normalized() * speed
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

# Handles the double jump of the player, conditions, reset, and apply
func _double_jump() -> void:
	# Double jump reset when on ground
	if is_on_floor():
		_has_double_jumped = false
		return
	
	# Conditions
	if _has_double_jumped: return
	if not Input.is_action_just_pressed("jump"): return
	
	# Jump
	_has_double_jumped = true
	velocity.y = jump_force

# Sets a control variable if the _movement() function should be run or not
func set_do_movement(value : bool, delay : float = 0) -> void:
	if delay == 0:
		_do_movement = value
		return
	
	await get_tree().create_timer(delay).timeout
	_do_movement = value


func receive_damage(value : float, from : Node3D):
	# TODO damage
	
	set_do_movement(false)
	
	var dir_to_player : Vector3 = (global_position - from.global_position).normalized()
	dir_to_player.x *= knockback_force.x
	dir_to_player.z *= knockback_force.x
	dir_to_player.y = knockback_force.y
	velocity = dir_to_player
	
	set_do_movement(true, knockback_time)
