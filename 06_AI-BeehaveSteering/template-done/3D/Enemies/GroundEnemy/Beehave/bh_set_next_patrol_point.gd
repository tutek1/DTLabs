@tool
extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	# Get patrol idx from blackboard
	var patrol_point_idx : int = blackboard.get_value(GroundEnemyBH.BB_VAR.PATROL_POINT_IDX)
	
	# Set navmesh target
	var patrol_point : Vector3 = enemy.patrol_points[patrol_point_idx]
	enemy.navigation_agent_3d.target_position = patrol_point
	
	return SUCCESS
