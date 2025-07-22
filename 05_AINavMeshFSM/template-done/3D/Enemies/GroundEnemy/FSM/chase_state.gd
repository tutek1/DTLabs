class_name ChaseState
extends AbstractFSMState

@export var enter_scale_up : float = 1.5
@export var enter_pos_up : float = 0.6
@export var enter_tween_time : float = 0.2
@export var update_time : float = 1
@export var chase_max_dist : float = 30

var _last_update : float = -INF

func state_enter(enemy : GroundEnemyFSM) -> void:
	var tween : Tween = enemy.create_tween()
	
	# Tween up
	tween.tween_property(enemy, "scale:y", enter_scale_up, enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(enemy, "position:y", enter_pos_up, enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC).as_relative()
	
	# Tween down
	tween.tween_property(enemy, "scale:y", 1, enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(enemy, "position:y", -enter_pos_up, enter_tween_time)\
	.set_trans(Tween.TRANS_CUBIC).as_relative()

func state_physics_process(enemy : GroundEnemyFSM, delta : float) -> void:
	var player : Node3D = enemy.get_player()
	if player == null: return
	
	# Rotate to halfway to player
	var dir_to_player : Vector3 = (player.global_position - enemy.global_position)
	var velocity : Vector3 = enemy.velocity
	
	enemy.rotate_enemy(delta, dir_to_player * 0.5 + velocity * 0.5)
	
	# Recalculate path every so often
	if _last_update + update_time * 1000 < Time.get_ticks_msec():
		enemy.navigation_agent_3d.target_position = player.global_position
		_last_update = Time.get_ticks_msec()

func state_exit(_enemy : GroundEnemyFSM) -> void:
	pass
