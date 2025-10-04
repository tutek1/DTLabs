class_name CollisionAvoidance
extends SteeringBehavior

@export var avoidance_strength : float = 4
@export var max_look_ahead : float = 6
@export var avoidance_radius : float = 1.8
@export var normal_to_mid_mix : float = 0.25

const PLAYER_LAYER : int = 2

var _shape_cast : ShapeCast3D = null

func act(air_enemy : AirEnemy) -> Vector3:
	if _shape_cast == null:
		_create_shapecast(air_enemy)
	
	# Shapecast final position
	_shape_cast.target_position =\
		air_enemy.velocity.normalized() * (max_look_ahead + avoidance_radius)
	_shape_cast.force_shapecast_update()
	
	# Shapecast hit
	var force : Vector3
	if _shape_cast.is_colliding():
		
		var max_strength : float = 0
		var max_strength_idx : int = 0
		
		# Get each collision point and find the strongest
		for idx in range(0, _shape_cast.get_collision_count()):
			var curr_point : Vector3 = _shape_cast.get_collision_point(idx)
			
			# Strength of the possible collision point (distance - enemy radius)
			var strength : float = curr_point.distance_to(air_enemy.global_position) - avoidance_radius
			strength = max(strength * strength, 0.1) # makes the strength have curve effect x^2
			
			if strength < max_strength: continue
			
			max_strength = strength
			max_strength_idx = idx
		
		# Mid point, hit point, and normal vector of the hit
		var mid_point : Vector3 = (_shape_cast.get_collider(max_strength_idx)).global_position
		var normal : Vector3 = _shape_cast.get_collision_normal(max_strength_idx)
		var point : Vector3 = _shape_cast.get_collision_point(max_strength_idx)
		
		# The final force for the collision is a mix of the normal vector of hit point
		#  and the mid point of the object. It might be a bit confusing but works well.
		#  Only one of these directions can be used
		force = (normal / max_strength) * normal_to_mid_mix\
			  + ((point - mid_point).normalized() / max_strength) * (1 - normal_to_mid_mix)
	
	return force * avoidance_strength - air_enemy.velocity

# Draws all the collision points
func debug_draw(_air_enemy : AirEnemy) -> void:
	if _shape_cast.is_colliding():
		for idx in range(0, _shape_cast.get_collision_count()):
			DebugDraw3D.draw_sphere(_shape_cast.get_collision_point(idx), 0.1, Color.BLUE, 0.1)

# Creates a new shapecast node as the child of the air enemy to use as a shape cast
func _create_shapecast(air_enemy : AirEnemy):
	_shape_cast = ShapeCast3D.new()
	air_enemy.add_child(_shape_cast)
	
	_shape_cast.enabled = false
	_shape_cast.exclude_parent = true
	_shape_cast.collide_with_areas = false
	_shape_cast.collide_with_bodies = true
	_shape_cast.collision_mask = air_enemy.collision_mask - PLAYER_LAYER # 2 == player, do not avoid them
	_shape_cast.shape = air_enemy.collision_shape.shape.duplicate()
	_shape_cast.shape.radius = avoidance_radius
