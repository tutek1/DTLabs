@tool
extends ActionLeaf

@export var rotate_mode : GroundEnemyBH.ROTATE_MODE

func tick(_actor, blackboard: Blackboard):
	blackboard.set_value(GroundEnemyBH.BB_VAR.ROTATE_MODE, rotate_mode)
	return SUCCESS
