extends Node2D

func create_speech_bubble(message):
	$PanelContainer/RichTextLabel.text = "[center]" + message
	var new_tween = get_tree().create_tween()
	new_tween.tween_property($PanelContainer, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	print(message)
	
func start_fading_bubble():
	var new_tween = get_tree().create_tween()
	new_tween.tween_property($PanelContainer, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	new_tween.finished.connect(bubble_fade_out)

func bubble_fade_out():
	get_parent().destroy_bubble()

func text_fade_in():
	pass
