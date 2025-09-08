extends Sprite3D
class_name PuzzleSectionManager

@export var success_object : Node3D 
@export var success_function : String 

@export_category("Camera")
@export var cam_rot : Vector3

@export_category("Tweens")
@export var target_position : Vector3
@export var pos_tween_time : float = 0.2
@export var wait_tween_time : float = 0.5
@export var target_rotation : Vector3
@export var rot_tween_time : float = 0.5
@export var connect_anim_tween_time : float = 2
@export var tween_camera_time : float = 1

@onready var camera_target : Node3D = $CameraTarget
@onready var subviewport : SubViewport = $SubViewport
@onready var puzzle_manager : PuzzleManager = $SubViewport.get_child(0)
@onready var raycast_area : Area3D = $RaycastArea
@onready var raycast_collider : CollisionShape3D = $RaycastArea/CollisionShape3D

var _is_in_2D : bool = false
var _player3D : PlayerController3D
var _camera_pivot : PlayerCamera3D

func _ready() -> void:
	puzzle_manager.game_completed.connect(exit_2D)
	
	# Case of not doing the raycast area manually
	#_raycast_area = Area3D.new()
	#add_child(_raycast_area)
	#
	#_raycast_collider = CollisionShape3D.new()
	#_raycast_area.add_child(_raycast_collider)
	
	# Setup the correctly sized collision shape
	var box_shape : BoxShape3D = BoxShape3D.new()
	box_shape.size = Vector3(subviewport.size.x * pixel_size, subviewport.size.y * pixel_size, 0.1)
	raycast_collider.shape = box_shape


# Handles the translation of 3D mouse input into the 2D puzzle world
func _input(event):
	if not _is_in_2D: return
	if _player3D == null: return
	
	# Calling the raycast this often might be problematic
	if event is InputEventMouse:
		var mouse_pos : Vector2 = event.position
		
		# Calculate the shape of the ray
		var camera : Camera3D = _camera_pivot.get_camera()
		var from : Vector3 = camera.project_ray_origin(mouse_pos)
		var to : Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000
		
		# Get the current physics state space of the world and create raycast parameters
		var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var param : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		param.collide_with_areas = true  # Since our raycast area is an area
		var result : Dictionary = space_state.intersect_ray(param)
		
		# Check if we hit our raycast area 
		if result and result.collider == raycast_area:
			# This is local position to the Sprite3D object origin in pixels of the sprite
			var local_pix_pos : Vector3 = raycast_collider.to_local(result.position) / pixel_size
			
			# This is the position of the mouse in the puzzle world.
			# The half offsets (width and height) are needed because the sprite is centered.
			# The sign swap is also needed because the 2D world has its
			# origin in the upper left corner but sprite3D in the lower left
			var puzzle_world_pos = Vector2(local_pix_pos.x + subviewport.size.x/2.0, subviewport.size.y/2.0 - local_pix_pos.y)
			puzzle_manager.process_input_position(event, puzzle_world_pos)


# Called to enter the 2D world
func enter_2D(player3D : PlayerController3D) -> void:
	if _is_in_2D: return
	if player3D == null: return
	_is_in_2D = true
	_player3D = player3D
	_camera_pivot = get_viewport().get_camera_3d().get_parent_node_3d()
	
	# Disable controls
	player3D.set_controllable(false)
	
	# Tween player rotation
	await create_tween()\
	.tween_property(player3D, "rotation_degrees", target_rotation, rot_tween_time)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)\
	.finished
	
	# Wait a while
	await get_tree().create_timer(wait_tween_time).timeout
	
	# Tween player position
	player3D.velocity = (target_position - player3D.global_position) / pos_tween_time
	await get_tree().create_timer(pos_tween_time).timeout
	player3D.velocity = Vector3.ZERO
	
	# Tween to the correct location after walking there, just to be sure
	create_tween()\
	.tween_property(player3D, "global_position", target_position, pos_tween_time)\
	.finished
	
	# Play connect animation
	#player3D.set_connect_anim_bool(true)
	
	# Wait a while
	await get_tree().create_timer(connect_anim_tween_time).timeout
	
	# Turn on the puzzle
	puzzle_manager.turn_on()
	
	_camera_pivot.set_temp_target(camera_target)
	_camera_pivot.set_user_rotation_control(false)
	
	var rotation_radians : Vector3 =\
		Vector3(deg_to_rad(cam_rot.x), deg_to_rad(cam_rot.y), deg_to_rad(cam_rot.z))
	create_tween().tween_property(_camera_pivot, "quaternion", Quaternion.from_euler(rotation_radians), tween_camera_time)
	
	player3D.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Called to exit the 2D world
func exit_2D(success : bool) -> void:
	if not _is_in_2D: return
	if _player3D == null: return
	puzzle_manager.turn_off()
	
	# Call success function on success object
	if success:
		success_object.call(success_function)
	
	_is_in_2D = false
	
	# Tween camera and enable
	_camera_pivot.set_temp_target(null)
	await create_tween().tween_property(_camera_pivot, "quaternion", _player3D.quaternion, tween_camera_time).finished
	_camera_pivot.set_user_rotation_control(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Play disconnect animation
	_player3D.process_mode = Node.PROCESS_MODE_INHERIT
	_player3D.set_connect_anim_bool(false)
	
	# Wait a while
	await get_tree().create_timer(connect_anim_tween_time).timeout
	
	# Enable controls
	_player3D.set_controllable(true)


func get_is_in_2D() -> bool:
	return _is_in_2D
