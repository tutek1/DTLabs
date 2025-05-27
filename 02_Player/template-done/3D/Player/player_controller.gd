extends CharacterBody3D

@export var speed : Vector3

func _ready() -> void:
	pass

func _process(delta) -> void:
	pass

func _physics_process(delta) -> void:
	velocity = speed
	move_and_slide()
