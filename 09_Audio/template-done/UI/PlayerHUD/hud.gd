extends CanvasLayer

@export var player : PlayerController3D
@export var hp_gradient : Gradient

@export var malware_move_px : float = 200
@export var malware_tween_time : float = 0.5
@export var malware_stay_up_time : float = 3

enum MalwareStates
{
	DOWN = 0,
	GOING_UP = 1,
	UP = 2,
	GOING_DOWN = 3
}

@onready var hp_bar : TextureProgressBar = %HPBar
@onready var collectible_counter : Label = %CollectibleCounter
@onready var collectible_v_box : VBoxContainer = %CollectibleVBox

var _malware_state : MalwareStates
var _counter_tween : Tween
var _counter_up_pos : Vector2

func _ready() -> void:
	player.hp_change.connect(_update_hp)
	_update_hp()
	
	# Remember the starting position of the collectible counter
	await get_tree().process_frame
	
	_counter_up_pos = collectible_v_box.global_position
	
	collectible_v_box.global_position = _counter_up_pos + Vector2.DOWN * malware_move_px
	_malware_state = MalwareStates.DOWN
	
	# Connect the collectible_gathered signal and update it
	player.collectible_gathered.connect(_update_collectible_counter)
	_update_collectible_counter()

func _update_hp() -> void:
	var hp_ratio : float = GlobalState.player_stats.curr_health / GlobalState.player_stats.health
	
	hp_bar.value = hp_ratio
	hp_bar.tint_progress = hp_gradient.sample(hp_ratio)

func _update_collectible_counter() -> void:
	var collectible_count : int = GlobalState.player_stats.collectible_count
	collectible_counter.text = str(GlobalState.player_stats.collectible_count)
	
	# If the counter is going down or is down, move it up
	if _malware_state == MalwareStates.DOWN or _malware_state == MalwareStates.GOING_DOWN:
		if _counter_tween != null: _counter_tween.kill()
		
		# Animate
		_counter_tween = create_tween()
		_counter_tween.tween_property(collectible_v_box, "global_position", _counter_up_pos , malware_tween_time)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
		
		# State change wait
		_malware_state = MalwareStates.GOING_UP
		await _counter_tween.finished
		_malware_state = MalwareStates.UP
	
	# Wait to hide
	await get_tree().create_timer(malware_stay_up_time).timeout
	
	# A new collectible was gathered -> we should not move down, new collection will move it
	if collectible_count != GlobalState.player_stats.collectible_count: return
	
	# If the counter is UP, move it down
	if _malware_state == MalwareStates.UP:
		_counter_tween = create_tween()
		_counter_tween.tween_property(collectible_v_box, "global_position",\
			_counter_up_pos + Vector2.DOWN * malware_move_px, malware_tween_time)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
		
		# State change wait
		_malware_state = MalwareStates.GOING_DOWN
		await _counter_tween.finished
		_malware_state = MalwareStates.DOWN

# Master volume slider
func _on_master_slider_value_changed(value : float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)

# SFX volume slider
func _on_sfx_slider_value_changed(value : float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)

# Music volume slider
func _on_music_slider_value_changed(value : float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)

# Ambient volume slider
func _on_ambient_slider_value_changed(value : float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Ambient"), value)
