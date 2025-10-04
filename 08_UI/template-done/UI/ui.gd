extends CanvasLayer

@export var player : PlayerController3D

@onready var hp_bar : TextureProgressBar = %HPBar

func _ready():
	player.hp_change.connect(_update_hp)


func _update_hp() -> void:
	hp_bar.value = player.get_curr_hp() / player.stats.health
