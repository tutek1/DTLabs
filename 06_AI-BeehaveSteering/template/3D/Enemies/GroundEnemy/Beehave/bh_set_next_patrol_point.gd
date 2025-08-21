@tool
extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	# TODO Get patrol point idx and set target_position of the navigation agent
	
	return SUCCESS
