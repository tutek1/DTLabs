class_name Pursue
extends SteeringBehavior

@export var predict_mult : float = 1

var _last_act_force : Vector3

# Pursues the target, same as seek but adds the velocity of the target (is there is any!)
func act(air_enemy : AirEnemy) -> Vector3:
	var force : Vector3 = Vector3.ZERO
	
	# TODO Calculate the normalized pursue force, so that the enemy predicts the target movement
	# Hint: use `air_enemy.get_player()` (returns null when player is not seen)
	
	_last_act_force = force
	return force

func debug_draw(air_enemy : AirEnemy) -> void:
	var pos : Vector3 = air_enemy.global_position
	DebugDraw3D.draw_arrow(pos, pos + _last_act_force.normalized() * 4, Color.HOT_PINK, 0.05)
