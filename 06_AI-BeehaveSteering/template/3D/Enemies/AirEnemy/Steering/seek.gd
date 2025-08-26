class_name Seek
extends SteeringBehavior

var _last_act_force : Vector3

func act(air_enemy : AirEnemy) -> Vector3:
	var force : Vector3 = Vector3.ZERO
	
	# TODO: Calculate the steering force of seek and return it
	# Hint: use `air_enemy.get_target()` to get the current target position	

	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	DebugDraw3D.draw_arrow(pos, pos + _last_act_force.normalized() * 4, Color.PURPLE, 0.05)
