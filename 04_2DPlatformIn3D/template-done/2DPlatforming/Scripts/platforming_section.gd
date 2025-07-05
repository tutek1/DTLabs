extends Sprite3D

@export var camera_angle : Vector3
@export var success_push_force : Vector3
@export var failure_push_force : Vector3
@export var push_time : float = 0.3

@onready var platforming_manager : PlatformingManager2D = $SubViewport/LevelCodelabs
@onready var camera_target : Node3D = $CameraTarget

var _player_3d : PlayerController3D
var _is_in_2d : bool = false

func _ready() -> void:
	platforming_manager.turn_off()
	platforming_manager.platforming_complete.connect(_exit2D, ConnectFlags.CONNECT_DEFERRED)

func _physics_process(delta):
	_update_camera_target()

# When in 2D moves the 3D camera target to be at the same place as the 2D player
func _update_camera_target() -> void:
	if not _is_in_2d: return
	
	# Get the position, offset it, and multiply it by pixel size
	var player2D_position : Vector2 = platforming_manager.get_player2D().position
	camera_target.position.x = (player2D_position.x - texture.get_width()/2) * pixel_size
	camera_target.position.y = (-player2D_position.y + texture.get_height()/2) * pixel_size
	camera_target.position.z = 0.5

# Handles the transition from 3D to 2D platforming
func _enter2D() -> void:
	if _is_in_2d: return
	_is_in_2d = true
	
	# Turn on the 2D level
	platforming_manager.turn_on()
	
	# Move the player right
	_player_3d.position += Vector3.RIGHT * 2
	
	# Change the camera target
	_player_3d.camera_pivot.camera_target = camera_target
	_player_3d.camera_pivot.set_user_rotation_control(false, camera_angle)
	
	# Wait a frame before disabling
	await get_tree().process_frame
	_player_3d.scale = Vector3.ZERO
	_player_3d.process_mode = Node.PROCESS_MODE_DISABLED

# Handles the transition from 2D platforming to 3D 
func _exit2D(success : bool) -> void:
	if not _is_in_2d: return
	_is_in_2d = false
	
	# Turn off the 2D level
	platforming_manager.turn_off()
	
	# Enable the 3D Player
	_player_3d.scale = Vector3.ONE
	_player_3d.process_mode = Node.PROCESS_MODE_INHERIT
	_player_3d.global_position = camera_target.global_position
	_player_3d.velocity = success_push_force if success else failure_push_force
	
	# Change the camera target
	_player_3d.camera_pivot.camera_target = _player_3d
	_player_3d.camera_pivot.set_user_rotation_control(true, camera_angle)
	
	_player_3d.set_do_movement(false)
	await get_tree().create_timer(push_time).timeout
	_player_3d.set_do_movement(true)

# Upon body collision, check if it is the player and enter2D
func _on_area_3d_body_entered(body : Node3D) -> void:
	if body is PlayerController3D:
		_player_3d = body
		_enter2D()
