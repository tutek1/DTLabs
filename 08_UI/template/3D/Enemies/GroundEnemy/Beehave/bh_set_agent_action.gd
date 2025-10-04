@tool
extends ActionLeaf

@export var value : GroundEnemyBH.ACTIONS

func tick(_actor, blackboard: Blackboard):
	blackboard.set_value(GroundEnemyBH.BB_VAR.LAST_ACTION, value)
	return SUCCESS
