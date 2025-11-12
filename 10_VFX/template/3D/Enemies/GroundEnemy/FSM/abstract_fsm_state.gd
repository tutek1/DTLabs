class_name AbstractFSMState
extends Resource

# Called upon transition into the state
func state_enter(_enemy : GroundEnemyFSM) -> void:
	assert(false, "Do not use this abstract class!")

# Called every physics process frame
func state_physics_process(_enemy : GroundEnemyFSM, _delta : float) -> void:
	assert(false, "Do not use this abstract class!")

# Called upon transition from the state
func state_exit(_enemy : GroundEnemyFSM) -> void:
	assert(false, "Do not use this abstract class!")
