extends CharacterBody3D

@export var speed : float = 5
@export var rotation_speed : float = 4

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	pass

func _physics_process(delta : float) -> void:
	_movement()
	_rotate_player(delta)
	
	move_and_slide()

func _movement() -> void:
	var x_axis : float = Input.get_axis("left", "right")
	var z_axis : float = Input.get_axis("backward", "forward")
	
	var direction : Vector3 = Vector3(x_axis, 0, -z_axis)
	direction = basis * direction
	direction = direction.normalized()
	
	velocity = direction * speed

func _rotate_player(delta : float) -> void:
	if abs(velocity.x) < 0.01 and abs(velocity.z) < 0.01: return
	var angle : float = atan2(velocity.x, velocity.z) - PI
	
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)
