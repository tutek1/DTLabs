@tool
extends CooldownDecorator


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	wait_time = enemy.update_time
	
	return super.tick(actor, blackboard)
