@tool
extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	var enemy_pos : Vector3 = enemy.global_position
	
	# TODO Get player from blackboard
	# TODO Check distance from enemy 
	#		-> return SUCCESS if close enough
	#		-> return FAILURE if too far away and set IS_PLAYER_SEEN to false
	
	return null
