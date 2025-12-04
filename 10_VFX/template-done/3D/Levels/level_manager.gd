class_name LevelManager
extends Node

@export var player : PlayerController3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var hologramables : Array[Node] = get_tree().get_nodes_in_group("Hologramable")
	
	for node in hologramables:
		if node.has_method("set_player_ref"):
			node.set_player_ref(player)
		else:
			push_warning("Node %s tagged as `Hologramable` without `set_player_ref` function!" % [node.name])
