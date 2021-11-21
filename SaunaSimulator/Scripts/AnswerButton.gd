extends Area2D

var hover_mouse = false
var disable_button = true
var response_text = "positive"

func _ready():
	disable_button = true

func set_disabled(value):
	disable_button = value
	
	if disable_button:
		$Tween.interpolate_property(
			$Sprite,
			"modulate",
			$Sprite.modulate,
			Color(1.0, 1.0, 1.0, 0.0),
			0.5,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
	else:
		$Tween.interpolate_property(
			$Sprite,
			"modulate",
			$Sprite.modulate,
			Color(1.0, 1.0, 1.0, 1.0),
			0.5,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)

	$Tween.start()

func mouse_exit():
	hover_mouse = false
	
func mouse_enter():
	hover_mouse = true

func _input(event):
	if event.is_action_pressed("mouse_click") and hover_mouse and not disable_button:
		get_parent().get_parent().give_response(response_text)

