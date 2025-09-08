class_name PlayerProjectile
extends Area3D

@export var lifetime : float = 10

@onready var life_timer : Timer = $LifeTimer

var _damage : float
var _velocity : Vector3

# Start life time timer
func _ready() -> void:
	life_timer.start(lifetime)

# Move in with velocity
func _physics_process(delta : float) -> void:
	position += _velocity * delta

# Set the damage value
func set_damage(value : float) -> void:
	_damage = value

# Set the velocity of the projectile
func set_velocity(value : Vector3) -> void:
	_velocity = value

# Damage the body if Damagable and Destroy self
func _on_body_entered(body : Node3D) -> void:
	if body.is_in_group("Damagable"):
		print("shot " + body.name)
		body.damage(_damage, self)
	
	queue_free()

# Destroy on timeout
func _on_life_timer_timeout():
	queue_free()
