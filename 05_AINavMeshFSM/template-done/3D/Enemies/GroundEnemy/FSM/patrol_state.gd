class_name PatrolState
extends AbstractFSMState

@export var patrol_points : Array[Vector3]
@export var dist_treshold : float = 1.5


var _curr_patrol_idx : int = 0

# Called upon transition into the state
func state_enter(enemy : GroundEnemyFSM) -> void:
	var best_dist : float = enemy.global_position.distance_to(patrol_points[0])
	var best_idx : int = 0
	
	# Find the closest patrol point
	for idx in range(0, patrol_points.size()):
		var dist : float = enemy.global_position.distance_to(patrol_points[idx])
		
		if dist < best_dist:
			best_dist = dist
			best_idx = idx
	
	_curr_patrol_idx = best_idx
	enemy.navigation_agent_3d.target_position = patrol_points[best_idx]

# Called every physics process frame
func state_physics_process(enemy : GroundEnemyFSM, delta : float) -> void:
	enemy.rotate_enemy(delta, enemy.velocity)
	
	var curr_point : Vector3 = patrol_points[_curr_patrol_idx]
	
	# Alternative: enemy.navigation_agent_3d.is_target_reached()
	# + change the distance threshold of the `NavigationAgent3D` node
	
	# Check if the target is reached -> set a new one
	if enemy.global_position.distance_to(curr_point) < dist_treshold:
		_curr_patrol_idx += 1
		if _curr_patrol_idx >= len(patrol_points):
			_curr_patrol_idx = 0
		
		enemy.navigation_agent_3d.target_position = patrol_points[_curr_patrol_idx]

# Called upon transition from the state
func state_exit(enemy : GroundEnemyFSM) -> void:
	enemy.navigation_agent_3d.target_position = enemy.global_position
