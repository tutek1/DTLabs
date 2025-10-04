class_name PlatformingManager2D
extends Node

# Emitted when platforming ended with the result
signal platforming_complete(bool)

@export var player : PlayerController2D

var _start_pos : Vector2

# Connect the death of the player to emit the platforming complete signal
# Cache the start position so that we can reset the player
func _ready():
	player.player2D_died.connect(platforming_complete.emit.bind(false))
	_start_pos = player.position

# Starts the platforming section
func turn_on() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	player.scale = Vector2.ONE

# Ends the platforming section
func turn_off() -> void:
	player.scale = Vector2.ZERO
	player.position = _start_pos
	
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_DISABLED

# Returns a reference to the 2D player
func get_player2D() -> Node2D:
	return player

# When the player enters the win area end the platforming with success
func _on_win_area_body_entered(body):
	if not body is PlayerController2D: return
	
	platforming_complete.emit(true)
