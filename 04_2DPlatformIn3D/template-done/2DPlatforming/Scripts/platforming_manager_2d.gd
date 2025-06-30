class_name PlatformingManager2D
extends Node

@export var player : Node2D

func turn_on() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	player.scale = Vector2.ONE

func turn_off() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	player.scale = Vector2.ZERO

func get_player2D() -> Node2D:
	return player
