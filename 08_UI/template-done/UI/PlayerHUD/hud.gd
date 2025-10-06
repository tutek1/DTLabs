extends CanvasLayer

@export var player : PlayerController3D
@export var hp_gradient : Gradient


@onready var hp_bar : TextureProgressBar = %HPBar

func _ready() -> void:
	player.hp_change.connect(_update_hp)
	_update_hp()

func _update_hp() -> void:
	var hp_ratio : float = GlobalState.player_stats.curr_health / GlobalState.player_stats.health
	
	hp_bar.value = hp_ratio
	hp_bar.tint_progress = hp_gradient.sample(hp_ratio)
