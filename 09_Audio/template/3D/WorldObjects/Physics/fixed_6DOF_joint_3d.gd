extends Generic6DOFJoint3D

var _node_a : PhysicsBody3D
var _node_b : RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if _node_a != null: _node_a = get_node(node_a)
	_node_b = get_node(node_b)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not _node_b is RigidBody3D: return
	_linear_motor(delta)
	_linear_spring()

# Applies the linear motor based on set parameters
func _linear_motor(delta : float) -> void:
	var lin_vel : Vector3 = _node_b.linear_velocity
	
	# X motor
	if get_flag_x(FLAG_ENABLE_LINEAR_MOTOR):
		lin_vel.x += get_param_x(PARAM_LINEAR_MOTOR_FORCE_LIMIT) * delta
		var limit : float = get_param_x(PARAM_LINEAR_MOTOR_TARGET_VELOCITY)
		if abs(lin_vel.x) > limit:
			lin_vel.x = sign(lin_vel.x) * limit
	
	# Y motor
	if get_flag_y(FLAG_ENABLE_LINEAR_MOTOR):
		lin_vel.y += get_param_y(PARAM_LINEAR_MOTOR_FORCE_LIMIT) * delta
		var limit : float = get_param_y(PARAM_LINEAR_MOTOR_TARGET_VELOCITY)
		if abs(lin_vel.y) > limit:
			lin_vel.y = sign(lin_vel.y) * limit
	
	# Z motor
	if get_flag_z(FLAG_ENABLE_LINEAR_MOTOR):
		lin_vel.z += get_param_z(PARAM_LINEAR_MOTOR_FORCE_LIMIT) * delta
		var limit : float = get_param_z(PARAM_LINEAR_MOTOR_TARGET_VELOCITY)
		if abs(lin_vel.z) > limit:
			lin_vel.z = sign(lin_vel.z) * limit
	
	_node_b.linear_velocity = lin_vel

# Applies the linear spring based on set parameters
func _linear_spring() -> void:
	# Get the position and velocity (if there is any) of the node_a
	var node_a_pos : Vector3
	var node_a_vel : Vector3
	if _node_a != null:
		if _node_a is Node3D:
			node_a_pos = _node_a.global_position
		
		if _node_a is RigidBody3D:
			node_a_vel = _node_a.linear_velocity
		elif _node_a is CharacterBody3D:
			node_a_vel = _node_a.velocity
	else:
		node_a_pos = global_position
	
	# X spring
	if get_flag_x(FLAG_ENABLE_LINEAR_SPRING):
		var stiff = get_param_x(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_STIFFNESS)
		var damp = get_param_x(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_DAMPING)
		var eq = get_param_x(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_EQUILIBRIUM_POINT)
		
		# Relative position along axis
		var rel_pos : float = _node_b.global_position.x - node_a_pos.x
		var rel_vel : float = _node_b.linear_velocity.x - node_a_vel.x
		
		# Spring force calculation per axis
		var force : float = -stiff * (rel_pos - eq) - damp * rel_vel
		
		# Apply force along axis to both bodies
		_node_b.apply_central_force(force * Vector3.RIGHT)
	
	# Y spring
	if get_flag_y(FLAG_ENABLE_LINEAR_SPRING):
		var stiff = get_param_y(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_STIFFNESS)
		var damp = get_param_y(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_DAMPING)
		var eq = get_param_y(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_EQUILIBRIUM_POINT)
		
		# Relative position along axis
		var rel_pos : float = _node_b.global_position.y - node_a_pos.y
		var rel_vel : float = _node_b.linear_velocity.y - node_a_vel.y
		
		# Spring force calculation per axis
		var force : float = -stiff * (rel_pos - eq) - damp * rel_vel
		
		# Apply force along axis to both bodies
		_node_b.apply_central_force(force * Vector3.UP)
	
	# Z spring
	if get_flag_z(FLAG_ENABLE_LINEAR_SPRING):
		var stiff = get_param_z(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_STIFFNESS)
		var damp = get_param_z(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_DAMPING)
		var eq = get_param_z(Generic6DOFJoint3D.PARAM_LINEAR_SPRING_EQUILIBRIUM_POINT)
		
		# Relative position along axis
		var rel_pos : float = _node_b.global_position.z - node_a_pos.z
		var rel_vel : float = _node_b.linear_velocity.z - node_a_vel.z
		
		# Spring force calculation per axis
		var force : float = -stiff * (rel_pos - eq) - damp * rel_vel
		
		# Apply force along axis to both bodies
		_node_b.apply_central_force(force * Vector3.BACK)
