@tool
extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	var enemy_pos : Vector3 = enemy.global_position
	
	var player : PlayerController3D = blackboard.get_value(GroundEnemyBH.BB_VAR.PLAYER_NODE)
	
	if player.global_position.distance_to(enemy_pos) > enemy.chase_max_dist:
		blackboard.set_value(GroundEnemyBH.BB_VAR.IS_PLAYER_SEEN, false)
		return FAILURE
	
	return SUCCESS
