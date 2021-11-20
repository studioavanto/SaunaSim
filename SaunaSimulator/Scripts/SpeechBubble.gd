extends Node2D

func _ready():
	$BubbleInTween.connect("tween_all_completed", self, "bubble_fade_in")
	$BubbleOutTween.connect("tween_all_completed", self, "bubble_fade_out")
	$TextTween.connect("tween_all_completed", self, "text_fade_in")

func create_speech_bubble(message):
	$PanelContainer/RichTextLabel.bbcode_text = "[center]" + message
	
	$BubbleInTween.interpolate_property(
		$NinePatchRect,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$BubbleInTween.interpolate_property(
		$NinePatchRect,
		"position",
		Vector2(-95.0, -20.0),
		Vector2(-95.0, -60.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$BubbleInTween.start()

func bubble_fade_in():
	$TextTween.interpolate_property(
		$PanelContainer/RichTextLabel,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$TextTween.start()

func start_fading_bubble():
	$BubbleOutTween.interpolate_property(
		self,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$BubbleOutTween.interpolate_property(
		$NinePatchRect,
		"position",
		Vector2(-95.0, -60.0),
		Vector2(-95.0, -20.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$BubbleOutTween.start()

func bubble_fade_out():
	get_parent().destroy_bubble()

func text_fade_in():
	pass
