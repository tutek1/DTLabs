class_name Collectible
extends Area3D

@export var bob_time : float = 0.75
@export var bob_amount : float = 0.5
@export var rotation_time : float = 5
@export var move_time : float = 0.5
@export var min_scale : float = 0.1
@export var cam_offset : Vector3 = Vector3(-2.2, -1.2, -2)

var _is_collected : bool = false
var _start_position : Vector3

func _ready() -> void:
	_start_position = global_position
	
	# Rotation
	create_tween()\
	.set_loops(-1)\
	.tween_property(self, "rotation_degrees:y", 360, rotation_time).from_current()
	
	# Bobbing tween
	var bob_tween : Tween = create_tween()
	bob_tween.set_loops(-1)
	bob_tween.tween_property(self, "position:y", bob_amount, bob_time)\
	.as_relative()\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	bob_tween.chain().tween_property(self, "position:y", -bob_amount, bob_time)\
	.as_relative()\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

# On body enter, check if it is the player
func _on_body_entered(body: Node3D) -> void:
	if _is_collected: return
	
	if body is PlayerController3D:
		body.collectible_touched(self)
		
		# Tween to UI
		create_tween().tween_property(self, "scale", Vector3.ONE * min_scale, move_time)
		await create_tween().tween_method(_move_to_ui, 0.0, 1.0, move_time).finished
		
		queue_free()

# Tween method to move the collectible to the UI
func _move_to_ui(t : float) -> void:
	var cam : Camera3D = get_viewport().get_camera_3d()
	var offset_translated = cam.global_transform.basis * cam_offset
	global_position = lerp(_start_position, cam.global_position + offset_translated, t)
