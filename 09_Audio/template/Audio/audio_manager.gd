extends Node

const SFX_BUS : String = "SFX"

enum SFX_TYPE
{
	TEST_SOUND,
	PLAYER_WALK,
	PLAYER_JUMP,
	PLAYER_DOUBLE_JUMP,
	PLAYER_DAMAGED,
	PLAYER_SHOOT,
	COLLECTIBLE,
	GE_DAMAGED,
	GE_SHOOT,
	AE_DAMAGED,
}

@export var sfx_bank : Dictionary[SFX_TYPE, SFXSettings]

@onready var music_stream_player : AudioStreamPlayer = $MusicStreamPlayer

var _last_music_position : float
var _is_music_playing : bool
var _music_fade_tween : Tween

# Plays a sfx sound based on type (no 3D sound)
func play_sfx(type : SFX_TYPE) -> void:
	# Check and get the settings
	if not sfx_bank.has(type): return
	var sfx_settings : SFXSettings = sfx_bank[type]
	
	# Handle sfx limit
	if sfx_settings.is_over_limit(): return
	sfx_settings.change_count(1)
	
	# TODO Create AudioStreamPlayer
	# Add as child of AudioManager
	# Set: bus, stream, volume
	# Connect finished signal to: streamplayer queue_free, sfx_settings change_count(-1)
	# Call Play 

# Same as play_sfx but plays the audio at location -> 3D sound
func play_sfx_at_location(type : SFX_TYPE, location : Vector3) -> void:
	# Check and get the settings
	if not sfx_bank.has(type): return
	var sfx_settings : SFXSettings = sfx_bank[type]
	
	# Handle sfx limit
	if sfx_settings.is_over_limit(): return
	sfx_settings.change_count(1)
	
	# TODO Create AudioStreamPlayer
	# Add as child of AudioManager
	# Set: bus, location, stream, volume, unit size
	# Connect finished signal to: streamplayer queue_free, sfx_settings change_count(-1)
	# Call Play 

# Same as play_sfx_at_location() but parents the audioplayer to a node for moving audio
func play_sfx_as_child(type : SFX_TYPE, parent : Node) -> void:
	# Check and get the settings
	if not sfx_bank.has(type): return
	var sfx_settings : SFXSettings = sfx_bank[type]
	
	# Handle sfx limit
	if sfx_settings.is_over_limit(): return
	sfx_settings.change_count(1)
	
	# TODO Create AudioStreamPlayer
	# Add as child of the parameter parent
	# Set: bus, stream, volume, unit size
	# Connect finished signal to: streamplayer queue_free, sfx_settings change_count(-1)
	# Call Play

# Starts to play music with settable fade-in
func play_music(fade_time : float = 0) -> void:
	if _is_music_playing: return
	_is_music_playing = true
	
	# Start playing
	music_stream_player.play(_last_music_position)
	
	# Tween the volume from current to 1
	if _music_fade_tween != null and _music_fade_tween.is_running():
		_music_fade_tween.kill()
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(music_stream_player, "volume_linear", 1, fade_time)

# Stops to play music with settable fade-out
func stop_music(fade_time : float = 0) -> void:
	if not _is_music_playing: return
	_is_music_playing = false
	
	# Tween the volume from current to 0
	if _music_fade_tween != null and _music_fade_tween.is_running():
		_music_fade_tween.kill()
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(music_stream_player, "volume_linear", 0, fade_time)
	
	# Wait for the tween to finish and check if the music has not started to play again
	await _music_fade_tween.finished
	if _is_music_playing: return
	
	# Remember the last position and stop
	_last_music_position = music_stream_player.get_playback_position()
	music_stream_player.stop()
