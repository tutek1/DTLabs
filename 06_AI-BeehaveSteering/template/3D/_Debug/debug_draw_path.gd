@tool
extends Node

@export var enabled : bool = true
@export var node : Node3D
@export var property : String
@export var loop : bool = true

func _process(_delta):
	if not enabled: return
	if node == null: return
	if property == "": return
	
	var points = get_nested_property(node, property)
	if not points is Array[Vector3]: return
	
	for idx in range(1, points.size()):
		DebugDraw3D.draw_line(points[idx-1], points[idx], Color.RED)
	
	if loop:
		DebugDraw3D.draw_line(points[points.size() - 1], points[0], Color.RED)

# Handles "." in property paths
func get_nested_property(node: Node3D, path: String):
	var parts = path.split(".")
	var value = node
	for part in parts:
		if value == null: return null
		value = value.get(part)
	return value
