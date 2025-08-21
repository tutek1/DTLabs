@tool
extends ActionLeaf

var _started : bool = false
var _finished : bool = false

func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	_started = false
	_finished = false

func tick(actor, _blackboard: Blackboard):
	if _started and not _finished: return RUNNING
	if _started and _finished: return SUCCESS
	
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	var base_deg : float = enemy.rotation_degrees.y
	var tween : Tween = create_tween()
	tween.tween_property(enemy, "rotation_degrees:y", base_deg + enemy.look_around_deg, enemy.look_around_time)
	tween.chain().tween_property(enemy, "rotation_degrees:y", base_deg, enemy.look_around_time)
	tween.chain().tween_property(enemy, "rotation_degrees:y", base_deg - enemy.look_around_deg, enemy.look_around_time)
	tween.chain().tween_property(enemy, "rotation_degrees:y", base_deg, enemy.look_around_time)
	tween.finished.connect(finish_tween)
	
	_started = true
	
	return RUNNING

func finish_tween() -> void:
	print("finished tween")
	_finished = true
