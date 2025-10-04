class_name Arrival
extends SteeringBehavior

@export var slowing_radius : float = 10

var _last_act_force : Vector3

# Calculates the arrive steering force, similar to seek but does not overshoot the target
func act(air_enemy : AirEnemy) -> Vector3:
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var force : Vector3 = to_target.normalized() * air_enemy.fly_acceleration
	
	# Calculate the coeficient if we should slowdown or not
	var distance : float = to_target.length()
	var coef : float = (distance / slowing_radius)
	coef = clamp(coef, 0.0, 1.0)
	coef = pow(coef, 3)
	
	# Lerp from deceleration to acceleration 
	force = lerp(-air_enemy.velocity, force, coef)
	
	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var distance : float = to_target.length()
	var factor : float = clamp(distance / slowing_radius, 0.0, 1.0)
	DebugDraw3D.draw_sphere(pos - air_enemy.basis.z * 2, factor, Color.YELLOW)
	DebugDraw3D.draw_arrow(pos, pos + _last_act_force/4, Color.YELLOW, 0.05)
