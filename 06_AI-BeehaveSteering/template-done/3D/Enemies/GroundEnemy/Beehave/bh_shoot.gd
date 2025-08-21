@tool
extends ActionLeaf

var projectile_prefab : PackedScene = preload("res://3D/Enemies/Projectiles/electric_projectile.tscn")

var _start_time : float

func before_run(actor: Node, blackboard: Blackboard) -> void:
	_start_time = Time.get_ticks_msec()

func tick(actor, blackboard: Blackboard):
	if not actor is GroundEnemyBH: return FAILURE
	var enemy : GroundEnemyBH = actor as GroundEnemyBH
	
	# Stop
	enemy.navigation_agent_3d.target_position = enemy.global_position
	
	# Wait for a while
	if _start_time + enemy.shoot_wait * 1000 > Time.get_ticks_msec():
		return RUNNING
	
	# Shoot
	var projectile : ElectricProjectile = projectile_prefab.instantiate()
	projectile.initialize(blackboard.get_value(GroundEnemyBH.BB_VAR.PLAYER_NODE))
	projectile.position = enemy.global_position
	enemy.get_tree().current_scene.add_child(projectile)
	
	return SUCCESS
