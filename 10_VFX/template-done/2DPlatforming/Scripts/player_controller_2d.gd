class_name PlayerController2D
extends CharacterBody2D

signal player2D_died

@export_category("Horizontal")
@export var speed : float = 175
@export var acceleration : float = 1200
@export var dampening : float = 30

@export_category("Vertical")
@export var gravity : float = 627.84
@export var jump_force : float = -240.0

var _has_double_jumped : bool = false

func _physics_process(delta : float) -> void:
	_movement(delta)
	_apply_gravity(delta)
	_jump()
	_double_jump()
	
	move_and_slide()
	_process_new_collision()

# Handles the horizontal movement of the player
func _movement(delta : float) -> void:
	var x_axis : float = Input.get_axis("left", "right")
	
	# Add the new velocity
	velocity.x += x_axis * delta * acceleration
	
	# Clamp max speed
	if abs(velocity.x) > speed:
		velocity.x = sign(velocity.x) * speed
	
	# Dampening if not moving
	if abs(x_axis) < 0.01:
		velocity.x *= clamp(1 - dampening * delta, 0, 1)

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

# Handles new collisions that happened this frame after move_and_slide
func _process_new_collision():
	for i in get_slide_collision_count():
		var collision : KinematicCollision2D = get_slide_collision(i)
		var collider : Object = collision.get_collider()
		
		# Check if collider is tilemap
		if collider is TileMapLayer:
			var tile_rid : RID = collision.get_collider_rid()
			var tile_coords : Vector2 = collider.get_coords_for_body_rid(tile_rid)
			
			# Check if the collided tile should damage the player
			if collider.get_cell_tile_data(tile_coords).get_custom_data("DamageOnTouch"):
				player2D_died.emit()
				#get_tree().reload_current_scene()
				return
