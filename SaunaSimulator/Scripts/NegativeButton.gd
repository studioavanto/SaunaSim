extends Area2D

var hover_mouse = false
var disable_button = true
var response_text = "negative"

func _ready():
	disable_button = true

func set_disabled(value):
	disable_button = value
	
	if disable_button:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)

func mouse_exit():
	hover_mouse = false
	
func mouse_enter():
	hover_mouse = true

func _process(_delta):
	if Input.is_action_just_pressed("mouse_click") and hover_mouse and not disable_button:
		get_parent().get_parent().give_response(response_text)
