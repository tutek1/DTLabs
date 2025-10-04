@tool
extends ConditionLeaf


func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value(GroundEnemyBH.BB_VAR.IS_PLAYER_SEEN):
		return SUCCESS
	
	return FAILURE
