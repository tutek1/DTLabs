class_name SteeringBehavior
extends Resource

# Called every frame, should return normalized force unless the magnitude plays a role 
func act(air_enemy : AirEnemy) -> Vector3:
	assert(false, "Do not use SteeringBehavior abstract class! Method `act()`")
	return Vector3.ZERO

# Called every frame if draw_debug is enabled
func debug_draw(air_enemy : AirEnemy) -> void:
	assert(false, "Do not use SteeringBehavior abstract class! Method `debug_draw()`")
