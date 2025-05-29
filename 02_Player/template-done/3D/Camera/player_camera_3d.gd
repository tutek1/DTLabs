extends Camera3D

@export var camera_target : Node3D
@export var camera_offset : Vector3 = Vector3(0, 2, 5)
@export var follow_speed : float = 2


func _physics_process(delta : float) -> void:
	_follow_target(delta)

func _follow_target(delta : float) -> void:
	position = lerp(position, camera_target.position + camera_offset, follow_speed * delta)
