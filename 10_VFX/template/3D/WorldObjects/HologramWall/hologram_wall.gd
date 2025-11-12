extends StaticBody3D

@onready var collision_shape_3d : CollisionShape3D = $CollisionShape3D
@onready var mesh : MeshInstance3D = $CollisionShape3D/MeshInstance3D
@onready var material : Material = mesh.get_active_material(0)

var _player : PlayerController3D = null
var _was_in_hologram : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _player == null: return
	material.set("shader_parameter/PlayerPos", _player.global_position)
	
	if not _was_in_hologram and _player.get_is_hologram():
		collision_shape_3d.disabled = true
		create_tween()\
		.tween_property(material, "shader_parameter/HologramAmount", _player.hologram_distance, _player.hologram_tween_time)
	elif _was_in_hologram and not _player.get_is_hologram():
		collision_shape_3d.disabled = false
		create_tween()\
		.tween_property(material, "shader_parameter/HologramAmount", 0, _player.hologram_tween_time)
	
	_was_in_hologram = _player.get_is_hologram()

func set_player_ref(player : PlayerController3D) -> void:
	_player = player
