@tool
extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	var enemy_pos : Vector3 = enemy.global_position
	
	var patrol_point_idx : int = blackboard.get_value(GroundEnemyBH.BB_VAR.PATROL_POINT_IDX)
	var curr_patrol_point : Vector3 = enemy.patrol_points[patrol_point_idx]
	
	if enemy_pos.distance_to(curr_patrol_point) < enemy.distance_threshold:
		return SUCCESS
	
	return FAILURE
