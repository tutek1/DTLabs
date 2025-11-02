class_name Collectible
extends Area3D

@export_category("Animation")
@export var bob_time : float = 0.75
@export var bob_amount : float = 0.5
@export var rotation_time : float = 5
@export var move_time : float = .5
@export var min_scale : float = 0.01

@export_category("HUD Constants")
@export var cam_distance : float = 5
@export var lb_viewport_offset : Vector2 = Vector2(170, -80)

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
	var viewport : Viewport = get_viewport()
	var cam : Camera3D = viewport.get_camera_3d()
	var view_size : Vector2 = viewport.get_visible_rect().size
	var screen_pos : Vector2 = Vector2(0, view_size.y) + lb_viewport_offset
	
	# On screen position to world
	var ray_origin : Vector3 = cam.project_ray_origin(screen_pos)
	var ray_direction : Vector3 = cam.project_ray_normal(screen_pos)
	var target_pos : Vector3 = ray_origin + ray_direction * cam_distance
	
	global_position = lerp(_start_position, target_pos, t)
