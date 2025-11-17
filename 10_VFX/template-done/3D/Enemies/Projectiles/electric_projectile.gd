class_name ElectricProjectile
extends Area3D

@export_category("Mesh")
@export var mesh_array : Array[ArrayMesh]
@export var mesh_switch_time : float = 0.6

@export_category("Mechanics")
@export var fly_speed : float = 10
@export var homing_rate : float = 1.5
@export var lifetime : float = 10
@export var damage : float = 10
@export var knockback_force : Vector2 = Vector2(6, 7)
@export var knockback_time : float = 0.75

@export_category("Visual")
@export var rotation_speed : float = 3
@export var scale_down : float = 0.5
@export var scale_up : float = 0.85
@export var scale_up_time : float = 0.4
@export var death_time : float = 0.4

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D
@onready var mesh_switch_timer : Timer = $MeshSwitchTimer
@onready var life_timer = $LifeTimer

var velocity_direction : Vector3

var _mesh_idx : int = 0
var _rotation_axis : Vector3
var _player : PlayerController3D
var _is_dying : bool


func initialize(player : PlayerController3D) -> void:
	_player = player

# Called when the node enters the scene tree for the first time.
func _ready():
	# Rotate
	_rotation_axis = Vector3(randf() * 2 - 1,randf() * 2 - 1,randf() * 2 - 1)
	_rotation_axis = _rotation_axis.normalized()
	
	# Scale up and down
	var scale_tween : Tween = create_tween()
	scale_tween.set_loops()
	scale_tween.tween_property(mesh_instance_3d, "scale", Vector3.ONE * scale_up, scale_up_time)
	scale_tween.chain().tween_property(mesh_instance_3d, "scale", Vector3.ONE * scale_down, scale_up_time)
	
	# Lifetime
	life_timer.start(lifetime)
	life_timer.timeout.connect(_destroy)
	
	# Mesh switching setup
	mesh_switch_timer.wait_time = mesh_switch_time
	mesh_switch_timer.timeout.connect(_switch_mesh)
	
	_switch_mesh()
	
	# Linear velocity setup
	if _player == null: return
	velocity_direction = global_position.direction_to(_player.global_position)

func _physics_process(delta) -> void:
	if _is_dying: return
	
	rotate_object_local(_rotation_axis, rotation_speed * delta)
	global_position += velocity_direction * fly_speed * delta
	
	# Uncomment the next line after installing the DebugDraw3D plugin
	# to see the travel direction
	DebugDraw3D.draw_arrow(global_position, global_position + velocity_direction * 2, Color.GREEN, 0.1)
	
	if _player == null: return
	var dir_to_player : Vector3 = (_player.global_position - global_position).normalized()
	velocity_direction = lerp(velocity_direction, dir_to_player, homing_rate * delta).normalized()

func _switch_mesh():
	mesh_instance_3d.mesh = mesh_array[_mesh_idx]
	
	_mesh_idx += 1
	if _mesh_idx >= len(mesh_array):
		_mesh_idx = 0

func _destroy() -> void:
	if _is_dying: return
	_is_dying = true
	
	await create_tween().tween_property(self, "scale", Vector3.ONE * 0.001, death_time)\
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT).finished
	queue_free()

func _on_body_entered(body : Node3D):
	if _is_dying: return
	
	_destroy()
	
	if body is PlayerController3D:
		body.receive_damage(damage, self)
