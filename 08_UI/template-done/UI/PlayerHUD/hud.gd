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

var _malware_state : MalwareStates

@onready var hp_bar : TextureProgressBar = %HPBar
@onready var collectible_counter : Label = %CollectibleCounter
@onready var collectible_v_box = $HBoxContainer/CollectibleVBox

func _ready() -> void:
	player.hp_change.connect(_update_hp)
	_update_hp()
	
	player.collectible_gathered.connect(_update_collectible_counter)
	_update_collectible_counter()

func _update_hp() -> void:
	var hp_ratio : float = GlobalState.player_stats.curr_health / GlobalState.player_stats.health
	
	hp_bar.value = hp_ratio
	hp_bar.tint_progress = hp_gradient.sample(hp_ratio)

func _update_collectible_counter() -> void:
	collectible_counter.text = str(GlobalState.player_stats.collectible_count)
	
	#696
	#900
