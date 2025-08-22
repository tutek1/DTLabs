class_name Arrival
extends SteeringBehavior

@export var slowing_radius : float = 2

var _last_act_force : Vector3

# Calculates the arrive steering force, similar to seek but does not overshoot the target
func act(air_enemy : AirEnemy) -> Vector3:
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var distance : float = to_target.length()
	
	# Calculate the desired speed
	var desired_speed = air_enemy.fly_speed
	if distance < slowing_radius:
		desired_speed = air_enemy.fly_speed * (distance / slowing_radius)
	
	# Calculate the desired velocity and move by the difference to velocity
	var desired_velocity : Vector3 = to_target.normalized() * desired_speed
	var force : Vector3 = desired_velocity - air_enemy.velocity
	
	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var distance : float = to_target.length()
	var factor : float = clamp(distance / slowing_radius, 0.0, 1.0)
	DebugDraw3D.draw_sphere(pos - air_enemy.basis.z * 2, factor, Color.YELLOW)
