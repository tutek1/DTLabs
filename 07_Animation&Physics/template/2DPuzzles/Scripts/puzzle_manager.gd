extends Node2D
class_name PuzzleManager

signal game_completed(success : bool)
signal cable_update

@export var ground_tilemap : TileMapLayer
@export var connection_tilemap : TileMapLayer
@export var IO_tilemap : TileMapLayer

@export_category("Flood Fill Propagation")
@export var use_flood_fill_change : bool
@export var flood_fill_wait : float = 0.01

var _gates : Array[Gate]
var _is_on : bool = false

func _ready():
	cable_update.connect(_update_outputs)
	
	call_deferred("_connect_gate_signals")
	call_deferred("_update_cable_states", Vector2i.ZERO, false)
	
	turn_on()


func turn_on() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT


func turn_off() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _connect_gate_signals():
	for scene_tile in connection_tilemap.get_children():
		if scene_tile is Gate:
			cable_update.connect(scene_tile.cable_update)
			scene_tile.gate_state_change.connect(_update_cable_states)
			_gates.push_back(scene_tile)


# Handle the mouse input (ONLY IN 2D)
func _input(event) -> void:
	if not event is InputEventMouse: return
	process_input_position(event, get_global_mouse_position())


# Processes given mouse event and position
func process_input_position(event : InputEventMouse, pos : Vector2):
	var tilemap_pos : Vector2i = ground_tilemap.local_to_map(pos)
	
	# On button press handle Input and cables
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_cable(tilemap_pos)
			_switch_inputs(tilemap_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_remove_cable(tilemap_pos)
			_switch_inputs(tilemap_pos)
	
	# While holding a the mouse buttons and moving only place and remove cables
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_place_cable(tilemap_pos)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_remove_cable(tilemap_pos)


# Places a cable on a given tilemap position
func _place_cable(tilemap_pos : Vector2i):
	var tile_data : TileData = ground_tilemap.get_cell_tile_data(tilemap_pos)
	if tile_data == null or not tile_data.get_custom_data("Placeable"): return
	if connection_tilemap.get_cell_atlas_coords(tilemap_pos) != Globals2DPuzzle.EMPTY_TILE: return
	
	connection_tilemap.set_cells_terrain_connect([tilemap_pos], 0, 0)
	_update_cable_states(tilemap_pos)


# Removes a placed cable from given tilemap position on tiles which are placeable
func _remove_cable(tilemap_pos : Vector2i):
	var tile_data : TileData = ground_tilemap.get_cell_tile_data(tilemap_pos)
	if tile_data == null or not tile_data.get_custom_data("Placeable"): return
	if connection_tilemap.get_cell_atlas_coords(tilemap_pos) == Globals2DPuzzle.EMPTY_TILE: return
	
	connection_tilemap.set_cells_terrain_connect([tilemap_pos], 0, -1)
	_update_cable_states(tilemap_pos)


# Switches input on given position, if position does not have input -> does nothing
func _switch_inputs(tilemap_pos : Vector2i):
	if IO_tilemap.get_cell_atlas_coords(tilemap_pos) == Globals2DPuzzle.INPUT_ON_COORDS:
		IO_tilemap.set_cell(tilemap_pos, 0, Globals2DPuzzle.INPUT_OFF_COORDS)
		_update_cable_states(tilemap_pos)
	elif IO_tilemap.get_cell_atlas_coords(tilemap_pos) == Globals2DPuzzle.INPUT_OFF_COORDS:
		IO_tilemap.set_cell(tilemap_pos, 0, Globals2DPuzzle.INPUT_ON_COORDS)
		_update_cable_states(tilemap_pos)


# Updates the cables based on gates and input power sources
func _update_cable_states(tilemap_pos : Vector2i, use_flood_fill : bool = use_flood_fill_change):
	var power_sources : Array = []
	
	# Get all the input tiles and prepare arrays for flood-fill
	for pos : Vector2i in IO_tilemap.get_used_cells():
		var atlas_coords : Vector2i = IO_tilemap.get_cell_atlas_coords(pos)
		if atlas_coords == Globals2DPuzzle.INPUT_ON_COORDS or\
		   atlas_coords == Globals2DPuzzle.ALWAYS_ON_COORDS:
			power_sources.push_back(pos)
	
	# Get all gates that are pushing power though
	for gate : Gate in _gates:
		if gate.is_on():
			power_sources.push_back(gate.output_pos())
	
	if use_flood_fill:
		# Flood fill to find where the cable should be on and where off
		var cables_ON_lookup : Dictionary = _ff_get_on_cables(power_sources)
		
		# Flood fill to change the states of the cables
		_ff_apply_new_state(tilemap_pos, cables_ON_lookup,_update_counter)
		_update_counter += 1
	else:
		# Instantly update all cables
		#cableON_tilemap.clear()
		_instant_change_cables_state(power_sources)


# Updates the output tiles (light bulbs), called every tile update
func _update_outputs():
	var are_all_outputs_on : bool = true
	
	for IO_tile_pos in IO_tilemap.get_used_cells():
		# Check if tile is output tile
		if IO_tilemap.get_cell_atlas_coords(IO_tile_pos) == Globals2DPuzzle.OUTPUT_OFF_COORDS or\
		   IO_tilemap.get_cell_atlas_coords(IO_tile_pos) == Globals2DPuzzle.OUTPUT_ON_COORDS:
			
			# Check the cable under the output
			var is_on : bool = connection_tilemap.get_cell_alternative_tile(IO_tile_pos) == 0
			
			if is_on:
				IO_tilemap.set_cell(IO_tile_pos, 0, Globals2DPuzzle.OUTPUT_ON_COORDS)
			else:
				IO_tilemap.set_cell(IO_tile_pos, 0, Globals2DPuzzle.OUTPUT_OFF_COORDS)
				are_all_outputs_on = false
	
	if are_all_outputs_on:
		game_completed.emit(true)
		_is_on = false
		print("2D puzzle complete!")

# ------------------------Instant-change-cable-state----------------------
func _instant_change_cables_state(power_sources : Array) -> void:
	var cables_ON_dict : Dictionary # [Vector2i pos] = bool
	var queue : Array = power_sources
	
	while not queue.is_empty():
		var current_pos : Vector2i = queue.pop_front()
		
		# Do not visit same node twice
		if cables_ON_dict.has(current_pos): continue
		cables_ON_dict[current_pos] = true
		
		# Do not care if ON or OFF cable is not present
		if not _is_cable_present(current_pos): continue
		
		# Push neighbors in
		queue.push_back(current_pos + Vector2i.UP)
		queue.push_back(current_pos + Vector2i.DOWN)
		queue.push_back(current_pos + Vector2i.RIGHT)
		queue.push_back(current_pos + Vector2i.LEFT)
	
	for tile_pos in connection_tilemap.get_used_cells():
		if not _is_cable_present(tile_pos): continue
		
		if cables_ON_dict.has(tile_pos):
			connection_tilemap.set_cell(tile_pos, 0, connection_tilemap.get_cell_atlas_coords(tile_pos), 0)
		else:
			connection_tilemap.set_cell(tile_pos, 0, connection_tilemap.get_cell_atlas_coords(tile_pos), 1)
	
	cable_update.emit()


# ------------------------Flood-fill-cable-state--------------------------
# used to not override new changes with old ones
var _tile_update_counter : Dictionary
var _update_counter : int = 0

# Uses flood fill alg to return the dictionary of cables that should be turned on
func _ff_get_on_cables(power_sources : Array) -> Dictionary: 
	var visited : Dictionary # used to not run in cycles, [Vector2i pos] = bool
	var cables_ON_dict : Dictionary
	
	var queue : Array = power_sources
	
	# BFS from each power source to find all cables that should be turned on
	while not queue.is_empty():
		var current_pos : Vector2i = queue.pop_front()
		
		# Do not visit same node twice
		if visited.has(current_pos): continue
		visited[current_pos] = true
		
		# Do not propagate further if cable is not present
		if not _is_cable_present(current_pos): continue
		
		cables_ON_dict[current_pos] = true
		
		# Push neighbors in
		queue.push_back(current_pos + Vector2i.UP)
		queue.push_back(current_pos + Vector2i.DOWN)
		queue.push_back(current_pos + Vector2i.RIGHT)
		queue.push_back(current_pos + Vector2i.LEFT)
	
	return cables_ON_dict


# BFS node used for search
class FloodNode:
	var pos : Vector2i
	var depth : int
	
	func _init(_pos, _depth):
		pos = _pos
		depth = _depth


# Using BFS traverses in all direction from the point of change "from" using the cables_ON_lookup
# Each update is called with update_counter one higher so as to not override new updates with old ones
func _ff_apply_new_state(from: Vector2i, cables_ON_lookup : Dictionary, update_counter : int):
	var queue : Array[FloodNode] = [\
		FloodNode.new(from, 0),
		FloodNode.new(from + Vector2i.UP, 1),
		FloodNode.new(from + Vector2i.DOWN, 1),
		FloodNode.new(from + Vector2i.RIGHT, 1),
		FloodNode.new(from + Vector2i.LEFT, 1)
	]
	
	var last_depth : int = 0
	while not queue.is_empty():
		var node : FloodNode = queue.pop_front()
		
		# Check if tile was already updated or updated by newer update
		if _tile_update_counter.has(node.pos) and\
		   _tile_update_counter[node.pos] >= update_counter:
			continue
		
		# Limit the search to the cables tiles
		if not _is_cable_present(node.pos): 
			continue
		
		# Change cable state and update the counter for this tile
		if cables_ON_lookup.has(node.pos):
			connection_tilemap.set_cell(node.pos, 0, connection_tilemap.get_cell_atlas_coords(node.pos), 0)
			_tile_update_counter[node.pos] = update_counter
		else:
			connection_tilemap.set_cell(node.pos, 0, connection_tilemap.get_cell_atlas_coords(node.pos), 1)
			_tile_update_counter[node.pos] = update_counter
		
		# Once a new search depth was reached wait -> procedural
		if node.depth > last_depth:
			last_depth = node.depth
			cable_update.emit()
			await get_tree().create_timer(flood_fill_wait).timeout
		
		# Push neighbors in
		queue.push_back(FloodNode.new(node.pos + Vector2i.UP, node.depth + 1))
		queue.push_back(FloodNode.new(node.pos + Vector2i.DOWN, node.depth + 1))
		queue.push_back(FloodNode.new(node.pos + Vector2i.RIGHT, node.depth + 1))
		queue.push_back(FloodNode.new(node.pos + Vector2i.LEFT, node.depth + 1))


# Checks if a cable is placed on given tile position
func _is_cable_present(tile_pos : Vector2i):
	return connection_tilemap.get_cell_source_id(tile_pos) == 0 and\
		   connection_tilemap.get_cell_atlas_coords(tile_pos) != Globals2DPuzzle.EMPTY_TILE 
