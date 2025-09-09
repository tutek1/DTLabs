extends StaticBody3D
class_name PuzzleInteract

@export var complete_mesh : Mesh
@export var puzzle_section : PuzzleSectionManager

var _layer : int

func interact(player : PlayerController3D):
	if puzzle_section.get_is_in_2D():
		puzzle_section.exit_2D(false)
	else:
		puzzle_section.enter_2D(player)
		_layer = collision_layer
		collision_layer = 0

func success() -> void:
	$ConnectorMesh.mesh = complete_mesh
	collision_layer = _layer
