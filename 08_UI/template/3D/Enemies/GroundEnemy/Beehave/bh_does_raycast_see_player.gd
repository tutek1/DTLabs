@tool
extends ConditionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	var player : PlayerController3D = blackboard.get_value(GroundEnemyBH.BB_VAR.PLAYER_NODE)
	
	enemy.shoot_cast.enabled = true
	enemy.shoot_cast.target_position = enemy.shoot_cast.to_local(player.global_position)
	enemy.shoot_cast.force_raycast_update()
	enemy.shoot_cast.enabled = false
	
	if enemy.shoot_cast.get_collider() is PlayerController3D:
		return SUCCESS
	
	return FAILURE
