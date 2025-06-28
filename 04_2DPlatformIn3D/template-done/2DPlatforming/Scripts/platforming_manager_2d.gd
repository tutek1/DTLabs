extends Node



func turn_on() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT


func turn_off() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
