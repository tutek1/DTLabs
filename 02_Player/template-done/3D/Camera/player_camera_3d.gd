extends Node3D

@export var camera_target : Node3D
@export var camera_offset : Vector3 = Vector3(0, 1.5, 5)
@export var follow_speed : float = 5
@export var camera_sens : Vector2 = Vector2(0.04, 0.06)
@export var camera_limit : Vector2 = Vector2(-60,60)

@onready var camera_3d : Camera3D = $Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta : float) -> void:
	_follow_target(delta)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion: 
		_rotate_camera(event.relative.x, event.relative.y)

func _follow_target(delta : float) -> void:
	position = lerp(position, camera_target.position, follow_speed * delta)
	camera_3d.position = camera_offset

func _rotate_camera(x : float, y : float) -> void:
	rotation_degrees.x -= y * camera_sens.x
	rotation_degrees.y -= x * camera_sens.y
	
	rotation_degrees.x = clamp(rotation_degrees.x, camera_limit.x, camera_limit.y)
