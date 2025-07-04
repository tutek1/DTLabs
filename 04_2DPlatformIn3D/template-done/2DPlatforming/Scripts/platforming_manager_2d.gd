class_name PlatformingManager2D
extends Node

signal platforming_complete(bool)

@export var player : PlayerController2D

var start_pos : Vector2

func _ready():
	player.player2D_died.connect(platforming_complete.emit.bind(false))
	start_pos = player.position

func turn_on() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	player.scale = Vector2.ONE

func turn_off() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	player.scale = Vector2.ZERO
	player.position = start_pos

func get_player2D() -> Node2D:
	return player


func _on_win_area_body_entered(body):
	platforming_complete.emit(true)
