class_name PlayerController3D
extends CharacterBody3D

@export var camera_pivot : PlayerCamera3D
@export var stats : PlayerStats

@export_category("Physics")
@export var player_mass : float = 20
@export var gravity : float = -29.43

const ENEMY_LAYER = 4

var _has_double_jumped : bool = false
var _do_movement : bool = true
var _can_be_damaged : bool = true
var _interact_node_in_area : Node3D
var _controllable : bool = true
var _current_hp : float

func _ready() -> void:
	_current_hp = stats.health

func _process(delta : float) -> void:
	pass

func _physics_process(delta : float) -> void:
	_movement(delta)
	_rotate_player(delta)
	_apply_gravity(delta)
	_jump()
	_double_jump()
	_interact()
	
	move_and_slide()

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
	velocity.x += direction.x * delta * stats.acceleration
	velocity.z += direction.z * delta * stats.acceleration
	
	# Clamp max speed
	var horizontal_velocity : Vector3 = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() > stats.speed:
		horizontal_velocity = horizontal_velocity.normalized() * stats.speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	
	# Dampening if not moving
	if abs(z_axis) < 0.01 and abs(x_axis) < 0.01:
		var damp_coef : float = 1 - stats.dampening * delta
		damp_coef = clamp(damp_coef, 0, 1)
		
		velocity.x *= damp_coef
		velocity.z *= damp_coef

# Rotates the player based on the direction they are moving on the Y-axis
func _rotate_player(delta : float) -> void:
	if not _controllable: return
	if abs(velocity.x) < 0.01 and abs(velocity.z) < 0.01: return
	var angle : float = atan2(velocity.x, velocity.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, stats.rotation_speed * delta)

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
	#TODO
	pass

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
