class_name PlayerStats
extends Resource

@export_group("Entity")
@export var health : float = 100
@export var invincivility_time : float = 0.75
@export var knockback_force : Vector2 = Vector2(10, 8)
@export var knockback_time : float = 0.5

@export_group("Movement")
@export var speed : float = 7
@export var jump_force : float = 10

@export_category("Shooting")
@export var projectile : PackedScene = preload("res://3D/Player/Projectile/player_projectile.tscn")
@export var projectile_damage : float = 5
@export var projectile_speed : float = 30
@export var shoot_cooldown : float = 0.7

@export_group("Abilities")
@export var has_double_jump : bool

@export_category("Progression")
@export var collectible_count : int = 0
