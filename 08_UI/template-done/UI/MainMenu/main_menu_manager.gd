extends Control

@export var new_game_scene : PackedScene

# Changes the scene to the set one
func _start_new_game() -> void:
	get_tree().change_scene_to_packed(new_game_scene)

# Loads the savefile and changes the scene
func _continue_game() -> void:
	GlobalState.load_game()
	get_tree().change_scene_to_packed(new_game_scene)

func _exit_game() -> void:
	get_tree().quit()
