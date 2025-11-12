extends Node

@onready var grayscale_rect : ColorRect = %GrayscaleRect

var _grayscale_tween : Tween

func pulse_grayscale(amount : float, fade_in : float, wait_time : float, fade_out : float) -> void:
	if _grayscale_tween != null:
		_grayscale_tween.kill()
	
	_grayscale_tween = create_tween()
	_grayscale_tween\
	.tween_property(grayscale_rect.material, "shader_parameter/amount", amount, fade_in)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	_grayscale_tween.chain()\
	.tween_property(grayscale_rect.material, "shader_parameter/amount", 0, fade_out)\
	.set_delay(wait_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
