@tool
extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	var player : PlayerController3D = blackboard.get_value(GroundEnemyBH.BB_VAR.PLAYER_NODE)
	
	if not enemy.is_on_floor():
		return RUNNING
	
	var target : Vector3 = player.global_position
	enemy.navigation_agent_3d.target_position = target
	
	return SUCCESS
