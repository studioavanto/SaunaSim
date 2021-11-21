extends Node2D

export var sauna_cooldown = 0.001
export var loyly_warm_speed = 0.02
export var loyly_length = 1.0
export var enter_probability = 0.5
export var max_comfort = 100.0

var can_character_enter = true

var current_gamestate = GameState.START

var current_comfort = -1.0
var max_temperature = 1.0
var min_temperature = 0.0

var current_temperature = 0.5
var on_going_loyly = false

var intro_character = false
var available_characters = []
var seat_1 = null
var seat_2 = null
var used_characters = []

var door_open = true
var chosen_answer = 2

var sauna_characters = [
	preload("res://Scenes/Characters/IntroCharacter.tscn"),
	preload("res://Scenes/Characters/Character1.tscn"),
	preload("res://Scenes/Characters/Character2.tscn"),
	preload("res://Scenes/Characters/Character3.tscn"),
	preload("res://Scenes/Characters/Character4.tscn")
]

enum GameState{
	START,
	GAME,
	END
}

func _ready():
	$LoylyTimer.connect("timeout", self, "stop_loyly")
	$GameClock.connect("timeout", self, "time_proceeds")
	$CharacterEnterTimer.connect("timeout", self, "characters_can_enter")

	randomize()

func open_door():
	door_open = true
	$Door.animation = "auki"

func close_door():
	door_open = false
	$Door.animation = "kiinni"

func characters_can_enter():
	can_character_enter = true

func create_available_characters():
	clear_characters()
	for character in sauna_characters:
		var new_character = character.instance()
		$Characters.add_child(new_character)
		new_character.position = $StartPos.position
		available_characters.append(new_character)

func clear_characters():
	for character in $Characters.get_children():
		character.queue_free()

	intro_character = false
	available_characters.clear()
	used_characters.clear()
	seat_1 = null
	seat_2 = null

func give_dialogue_response(response):
	if seat_1.speaking:
		seat_1.give_response(response)
	else:
		seat_2.give_response(response)

func give_response(response):
	give_dialogue_response(response)

func start_conversation():
	$Ajatus/NegativeButton.set_disabled(false)
	$Ajatus/PositiveButton.set_disabled(false)
	$Ajatus/SilentButton.set_disabled(false)
	
func hide_conversation():
	$Ajatus/NegativeButton.set_disabled(true)
	$Ajatus/PositiveButton.set_disabled(true)
	$Ajatus/SilentButton.set_disabled(true)

func throw_loyly():
	$Pelaaja.animation = "loyl"
	$Sanko.animation = "eikauha"
	$Sanko/Highlight.animation = "eikauha"
	play_audio("loyly")
	
	$Sanko.disable_button = true
	on_going_loyly = true
	$LoylyTimer.start(loyly_length)

func play_audio(audio_id):
	$AudioManager.play_audio(audio_id)

func stop_loyly():
	on_going_loyly = false
	$Sanko.disable_button = false
	$Pelaaja.animation = "default"
	$Sanko.animation = "kauha"
	$Sanko/Highlight.animation = "kauha"

func get_temp_level():
	if current_temperature < 0.33:
		return 0
	elif current_temperature < 0.66:
		return 1
	else:
		return 2

func spend_time():
	current_comfort -= 1
	
	if current_comfort == 0:
		game_over()

func game_over():
	$GameClock.stop()
	fade_in_end_screen()
	current_gamestate = GameState.END

func start_game():
	create_available_characters()
	current_comfort = max_comfort
	$GameClock.start()

func quit_game():
	get_tree().quit()

func time_proceeds():
	spend_time()

	# Characters spend time
	if seat_1 !=  null:
		seat_1.spend_time(current_temperature)
	if seat_2 !=  null:
		seat_2.spend_time(current_temperature)
		
	# Check if someone wants to leave
	if not is_someone_speaking() and someone_sitting():
		var leaver = random_sitter()
		
		if leaver.wants_to_leave():
			leaver.exit_sauna($StartPos.position)

	# Check if someone wants to speak
	if not is_someone_speaking() and someone_sitting():
		var speaker = random_sitter()

		if speaker.wants_to_speak():
			speaker.start_speaking()

	# Check if new characters enter sauna
	if seats_left() and enter_probability > rand_range(0.0, 1.0) and can_character_enter:
		can_character_enter = false
		$CharacterEnterTimer.start()

		if seat_1 == null:
			seat_1 = character_enters_on_seat($Walk1Place.position, $Seat1Place.position)
		elif seat_2 == null:
			seat_2 = character_enters_on_seat($Walk2Place.position, $Seat2Place.position)

func someone_sitting():
	return seat_1 != null or seat_2 != null

func random_sitter():
	if seat_1 == null:
		return seat_2
	elif seat_2 == null:
		return seat_1

	if randi() % 2 == 1:
		return seat_1
	else:
		return seat_2

func character_has_exited(character):
	if character == seat_1:
		seat_1 = null
	elif character == seat_2:
		seat_2 = null

	used_characters.append(character)

func is_someone_speaking():
	if seat_1 != null and seat_1.speaking:
		return true
	if seat_2 != null and seat_2.speaking:
		return true
	
	return false

func seats_left():
	return seat_1 == null or seat_2 == null

func anyone_sitting():
	return not (seat_1 == null and seat_2 == null)

func character_enters_on_seat(walk_pos, seat_pos):
	if available_characters.size() == 0:
		if anyone_sitting():
			game_over()
		else:
			return

	var char_id = 0
	var new_char = null
	
	if intro_character:
		char_id = randi() % available_characters.size()
		new_char = available_characters[char_id]
	else:
		new_char = available_characters[char_id]

	available_characters.remove(char_id)
	new_char.enter_sauna(walk_pos, seat_pos)
	
	return new_char

func continue_scene():
	if current_gamestate == GameState.START:
		fade_out_start_screen()
		current_gamestate = GameState.GAME
		start_game()

	if current_gamestate == GameState.END:
		fade_out_end_screen()
		current_gamestate = GameState.START

func fade_out_start_screen():
	$STransitionTween.interpolate_property(
		$StartScreen,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$STransitionTween.start()

func fade_out_end_screen():
	$StartScreen.modulate = Color(1.0, 1.0, 1.0, 1.0)

	$STransitionTween.interpolate_property(
		$EndScreen,
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$STransitionTween.start()

func fade_in_end_screen():
	$STransitionTween.interpolate_property(
		$EndScreen,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		Color(1.0, 1.0, 1.0, 1.0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$STransitionTween.start()

func set_hoyry_level():
	var opacity = max((current_temperature - 0.2), 0.0)
	$Hoyryt.modulate = Color(1.0, 1.0, 1.0, opacity)

func _input(event):
	if event.is_action_pressed("continue"):
		continue_scene()
	if event.is_action_pressed("quit"):
		quit_game()

func _physics_process(delta):
	if not $DoorOpenZone.get_overlapping_areas().empty():
		if not door_open:
			open_door()
	else:
		if door_open:
			close_door()

	if on_going_loyly:
		current_temperature += loyly_warm_speed
	else:
		current_temperature -= sauna_cooldown

	if current_temperature > max_temperature:
		current_temperature = max_temperature
	
	if current_temperature < min_temperature:
		current_temperature = min_temperature

	$SaunaTemp.set_temperature(current_temperature)
	set_hoyry_level()
