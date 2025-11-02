extends Node

const SAVE_PATH : String = "user://savegame.res" 

var player_stats : PlayerStats

func _ready():
	player_stats = PlayerStats.new()

func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		player_stats = ResourceLoader.load(SAVE_PATH)

func save_game() -> int:
	return ResourceSaver.save(player_stats, SAVE_PATH)
