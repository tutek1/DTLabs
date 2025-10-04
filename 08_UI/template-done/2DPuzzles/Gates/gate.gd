extends Node2D
class_name Gate

signal gate_state_change(coords : Vector2i)

@export var gate_type : GateType

const IN1_OFFSET : Vector2i = Vector2i(-1, -1)
const IN2_OFFSET : Vector2i = Vector2i(-1, 1)
const OUT_OFFSET : Vector2i = Vector2i(1, 0)

var _cable_tilemap : TileMapLayer
var _current_state : bool = false
var _last_state : bool = false
var _tilemap_pos : Vector2i
var _in1_pos : Vector2i
var _in2_pos : Vector2i
var _out_pos : Vector2i


enum GateType 
{
	AND,
	OR,
	XOR,
}

func _ready():
	_cable_tilemap = get_parent()
	
	_tilemap_pos = _cable_tilemap.local_to_map(position)
	_in1_pos = _tilemap_pos + IN1_OFFSET
	_in2_pos = _tilemap_pos + IN2_OFFSET
	_out_pos = _tilemap_pos + OUT_OFFSET


func cable_update() -> void:
	var input1_value : bool = _cable_tilemap.get_cell_alternative_tile(_in1_pos) == 0
	var input2_value : bool = _cable_tilemap.get_cell_alternative_tile(_in2_pos) == 0
	
	match gate_type:
		GateType.AND:
			_current_state = input1_value && input2_value
		GateType.OR:
			_current_state = input1_value || input2_value
		GateType.XOR:
			_current_state = input1_value != input2_value
	
	# Check if state changed
	if _current_state != _last_state:
		_last_state = _current_state
		gate_state_change.emit(_out_pos)


func is_on() -> bool:
	return _current_state


func output_pos() -> Vector2i:
	return _out_pos
