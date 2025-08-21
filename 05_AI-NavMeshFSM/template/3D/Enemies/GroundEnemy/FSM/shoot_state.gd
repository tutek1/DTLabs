class_name ShootState
extends AbstractFSMState

@export var shoot_cooldown : float = 3
@export var shoot_wait : float = 0.5


var projectile_prefab : PackedScene = preload("res://3D/Enemies/Projectiles/electric_projectile.tscn")

func state_enter(enemy : GroundEnemyFSM) -> void:
	enemy.navigation_agent_3d.target_position = enemy.global_position
	
	# TODO spawn projectile

func state_physics_process(enemy : GroundEnemyFSM, delta : float) -> void:
	var player : Node3D = enemy.get_player()
	if player == null: return
	
	# Rotate to player
	enemy.rotate_enemy(delta, player.global_position - enemy.global_position)

func state_exit(enemy : GroundEnemyFSM) -> void:
	pass

