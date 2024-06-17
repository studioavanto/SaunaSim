extends AnimatedSprite2D

var hover_mouse = false
var disable_button = false

func mouse_enter():
	hover_mouse = true
	var new_tween = get_tree().create_tween()
	new_tween.tween_property($HelpText, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	new_tween.parallel().tween_property($Highlight, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	
func mouse_exit():
	hover_mouse = false
	var new_tween = get_tree().create_tween()
	new_tween.tween_property($HelpText, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	new_tween.parallel().tween_property($Highlight, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

func _process(_delta):
	if Input.is_action_just_pressed("mouse_click") and hover_mouse and not disable_button:
		get_parent().throw_loyly()
