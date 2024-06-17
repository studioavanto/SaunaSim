extends Area2D

var disable_button = true
var response_text = "positive"

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

func _input(event):
	if event is InputEventMouseButton and not disable_button:
		get_parent().get_parent().give_response(response_text)
