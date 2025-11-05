class_name ShootState
extends AbstractFSMState

@export var shoot_cooldown : float = 3
@export var shoot_wait : float = 0.5

var projectile_prefab : PackedScene = preload("res://3D/Enemies/Projectiles/electric_projectile.tscn")

func state_enter(enemy : GroundEnemyFSM) -> void:
	enemy.navigation_agent_3d.target_position = enemy.global_position
	
	# Wait before shooting
	await enemy.get_tree().create_timer(shoot_wait).timeout
	
	# Spawn projectile
	var projectile : ElectricProjectile = projectile_prefab.instantiate()
	projectile.initialize(enemy.get_player())
	projectile.position = enemy.global_position
	enemy.get_tree().current_scene.add_child(projectile)
	
	AudioManager.play_sfx_at_location(AudioManager.SFX_TYPE.GE_SHOOT, enemy.global_position)
	
	enemy.set_can_shoot(false)

func state_physics_process(enemy : GroundEnemyFSM, delta : float) -> void:
	var player : Node3D = enemy.get_player()
	if player == null: return
	
	# Rotate to player
	enemy.rotate_enemy(delta, (player.global_position - enemy.global_position))

func state_exit(enemy : GroundEnemyFSM) -> void:
	enemy.shoot_cooldown_timer.start(shoot_cooldown)
