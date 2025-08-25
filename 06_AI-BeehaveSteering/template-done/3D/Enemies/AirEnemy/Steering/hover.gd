class_name Hover
extends SteeringBehavior

@export var hover_start_height : float = 1.75
@export var hover_end_height : float = 3

var _going_up : bool

# Hovers up and down starting from start_height until end_height is reached
func act(air_enemy : AirEnemy) -> Vector3:
	
	# Raycast to see how far below the ground is
	var ray_origin : Vector3 = air_enemy.global_position
	var ray_end : Vector3 = ray_origin + Vector3.DOWN * hover_end_height
	var space_state := air_enemy.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, air_enemy.collision_mask)
	var result : Dictionary = space_state.intersect_ray(query)
	
	# Raycast hit
	if result:
		var distance : float = air_enemy.global_position.distance_to(result["position"])
		# if low enough go up
		if distance < hover_start_height:
			_going_up = true
	# No hit
	else:
		_going_up = false
	
	return Vector3.UP * air_enemy.fly_acceleration if _going_up else Vector3.ZERO

func debug_draw(air_enemy : AirEnemy) -> void:
	if _going_up:
		DebugDraw3D.draw_sphere(air_enemy.global_position + Vector3.DOWN * hover_start_height, 0.5, Color.ORANGE)
