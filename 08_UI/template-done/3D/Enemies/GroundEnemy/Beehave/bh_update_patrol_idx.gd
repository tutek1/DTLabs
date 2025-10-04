@tool
extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	var patrol_point_idx : int = blackboard.get_value(GroundEnemyBH.BB_VAR.PATROL_POINT_IDX)

	# Update idx
	patrol_point_idx += 1
	if patrol_point_idx >= len(enemy.patrol_points):
		patrol_point_idx = 0
	
	blackboard.set_value(GroundEnemyBH.BB_VAR.PATROL_POINT_IDX, patrol_point_idx)
	
	return SUCCESS
