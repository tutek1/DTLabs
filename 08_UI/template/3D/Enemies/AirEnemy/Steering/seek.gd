class_name Seek
extends SteeringBehavior

var _last_act_force : Vector3

func act(air_enemy : AirEnemy) -> Vector3:
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var desired_velocity : Vector3 = to_target.normalized() * air_enemy.fly_acceleration
	
	var force : Vector3 = desired_velocity - air_enemy.velocity
	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	DebugDraw3D.draw_arrow(pos, pos + _last_act_force.normalized() * 4, Color.PURPLE, 0.05)
