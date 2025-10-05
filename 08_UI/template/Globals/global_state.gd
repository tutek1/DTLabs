extends Node

const SAVE_PATH : String = "user://savegame.res" 

var player_stats : PlayerStats

func _ready():
	player_stats = PlayerStats.new()

func load_game() -> void:
	pass

func save_game() -> int:
	return 1
