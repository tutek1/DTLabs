class_name SFXSettings
extends Resource

# -1 == no limit
@export var audio_clips : Array[AudioStream]
@export var limit : int = -1
@export_range(-50, 30) var volume_adjust : float = 0
@export_range(0, 100) var unit_size : float = 10

var _count : int = 0

func get_clip() -> AudioStream:
	return audio_clips.pick_random()

func change_count(value : int) -> void:
	_count += value
	if limit != -1:
		_count = min(limit, _count)

func is_over_limit() -> bool:
	return limit != -1 and _count >= limit
