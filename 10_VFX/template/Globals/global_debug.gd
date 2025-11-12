extends Node

# Check if this script was run in editor, if not delete self
func _ready() -> void:
	if not OS.has_feature("editor"):
		queue_free()
		return

func _input(event : InputEvent):
	# Check if the button was just pressed
	var just_pressed : bool = event.is_pressed() and not event.is_echo()
	if not just_pressed: return
	
	_switch_mouse_mode()
	_time_change()
	_toggle_music()
	_quick_save()

# Unlocks and locks the mouse
func _switch_mouse_mode() -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			print("DEBUG: Mouse freed")
		else:
			Input.mouse_mode =Input.MOUSE_MODE_CAPTURED
			print("DEBUG: Mouse captured")
			

# Changes the engine time scale (too high or too low may break physics)
func _time_change() -> void:
	if Input.is_key_pressed(KEY_F2):
		Engine.time_scale *= 0.5
		print("DEBUG: lowered time scale to => " + str(Engine.time_scale))
	if Input.is_key_pressed(KEY_F3):
		Engine.time_scale *= 2
		print("DEBUG: upped time scale to => " + str(Engine.time_scale))

func _toggle_music() -> void:
	if Input.is_key_pressed(KEY_F4):
		if AudioManager.music_stream_player.is_playing():
			print("DEBUG: Stopped music")
			AudioManager.stop_music(5)
		else:
			print("DEBUG: Started music")
			AudioManager.play_music(5)

func _quick_save() -> void:
	if Input.is_key_pressed(KEY_F5):
		var result : int = GlobalState.save_game()
		if result == 0:
			print("DEBUG: Quick Save Complete!")
		else:
			print("DEBUG: Quick Save Failed! Err num: %s" % [result])
