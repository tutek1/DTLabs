@tool
extends ConditionLeaf

@export var is_action : GroundEnemyBH.ACTIONS

func tick(_actor, blackboard: Blackboard):
	if blackboard.get_value(GroundEnemyBH.BB_VAR.LAST_ACTION) == is_action:
		return SUCCESS
	
	return FAILURE
