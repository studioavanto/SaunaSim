extends AnimatedSprite

var hover_mouse = false
var disable_button = false

func mouse_enter():
	hover_mouse = true
	$Tween.interpolate_property(
		$HelpText,
		"modulate",
		$HelpText.modulate,
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	$Tween.interpolate_property(
		$Highlight,
		"modulate",
		$Highlight.modulate,
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	
	$Tween.start()
	
func mouse_exit():
	hover_mouse = false
	
	$Tween.interpolate_property(
		$HelpText,
		"modulate",
		$HelpText.modulate,
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	$Tween.interpolate_property(
		$Highlight,
		"modulate",
		$Highlight.modulate,
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	$Tween.start()

func _process(_delta):
	if Input.is_action_just_pressed("mouse_click") and hover_mouse and not disable_button:
		get_parent().throw_loyly()
