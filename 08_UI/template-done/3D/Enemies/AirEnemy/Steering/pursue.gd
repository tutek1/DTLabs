class_name Pursue
extends SteeringBehavior

@export var predict_mult : float = 1

var _last_act_force : Vector3

# Pursues the target, same as seek but adds the velocity of the target (is there is any!)
func act(air_enemy : AirEnemy) -> Vector3:
	var to_target : Vector3 = air_enemy.get_target() - air_enemy.global_position
	var player : PlayerController3D = air_enemy.get_player()
	
	# If the enemy knows about the player (is hunting them) add velocity
	if player != null:
		to_target += player.velocity * predict_mult
	
	var desired_velocity : Vector3 = to_target.normalized() * air_enemy.fly_acceleration
	var force : Vector3 = desired_velocity - air_enemy.velocity
	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	DebugDraw3D.draw_arrow(pos, pos + _last_act_force.normalized() * 4, Color.HOT_PINK, 0.05)
