class_name PlayerStats
extends Resource

@export_group("Entity")
@export var health : float = 100
@export var invincivility_time : float = 0.75
@export var knockback_force : Vector2 = Vector2(10, 8)
@export var knockback_time : float = 0.5

@export_group("Horizontal Movement")
@export var speed : float = 7
@export var acceleration : float = 75
@export var dampening : float = 10

@export_group("Vertical Movement")
@export var rotation_speed : float = 8
@export var jump_force : float = 10
