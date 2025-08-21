@tool
extends ActionLeaf


func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	var tween : Tween = enemy.create_tween()
	
	# Tween up
	tween.tween_property(enemy, "scale:y", enemy.enter_scale_up, enemy.enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(enemy, "position:y", enemy.enter_pos_up, enemy.enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC).as_relative()
	
	# Tween down
	tween.tween_property(enemy, "scale:y", 1, enemy.enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(enemy, "position:y", -enemy.enter_pos_up, enemy.enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC).as_relative()
	
	return SUCCESS
