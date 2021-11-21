extends Node2D

export(String) var character_file_name

export var walk_speed = 30.0
export var speaking_probability = 0.2
export var comment_time = 4
export var dialogue_time = 6
export var stay_silent_time = 5
export var dialogue_max = 1
export var comfort_limit = -3
export var max_time_in_wrong_temp = 15
export var min_temp = 0.2
export var max_temp = 0.8
export var temp_comment_probability = 0.5
export var long_dialogue_id = "1"
export var long_dialogue_comfort = 2
export var bad_ending_comfort_limit = -2
export var good_ending_comfort_limit = 2

var exit_dialog = null
var cold_reactions = null
var hot_reactions = null
var normal_reactions = null
var dialogues = null

var has_not_spoken = []

var current_response = "silent"
var current_speech_bubble = null
var current_dialogue = "-1"
var text_id = "-1"
var speaking = false
var stay_silent = false

var cold_reaction_id = 0
var hot_reaction_id = 0
var time_in_wrong_temp = 0
var comfort = 0
var dialogues_done = 0
var next_position = null
var seat_position = null
var exiting = false

enum CharacterState {
	MOVING,
	SITTING,
	NULL
}

var current_state = CharacterState.NULL

var speech_bubble_scene = preload("res://Scenes/SpeechBubble.tscn")

func _ready():
	var char_file = File.new()
	char_file.open("res://Characters/" + character_file_name, File.READ)
	var data = parse_json(char_file.get_as_text())
	char_file.close()
	
	unpack_json_data(data)
	
	for dialog_id in dialogues.keys():
		if dialog_id != long_dialogue_id:
			has_not_spoken.append(dialog_id)
	
	$SpeechTimer.connect("timeout", self, "stop_speaking")
	$StaySilentTimer.connect("timeout", self, "stop_stay_silent")

func unpack_json_data(data):
	exit_dialog = data["exit_dialog"]
	cold_reactions = data["cold_reactions"]
	hot_reactions = data["hot_reactions"]
	normal_reactions = data["normal_reactions"]
	dialogues = data["dialogues"]

func spend_time(temperature):
	if current_state == CharacterState.SITTING:
		if temperature < min_temp or temperature > max_temp:
			if time_in_wrong_temp > max_time_in_wrong_temp:
				comfort -= 1
				time_in_wrong_temp = 0
			time_in_wrong_temp += 1
		else:
			time_in_wrong_temp = 0

func enter_sauna(position, seat_pos):
	z_index = 1
	$AnimatedSprite.animation = "walk"
	current_state = CharacterState.MOVING
	next_position = position
	seat_position = seat_pos
	
func exit_sauna(position):
	z_index = 1
	$AnimatedSprite.animation = "walk"
	current_state = CharacterState.MOVING
	next_position = position
	exiting = true
	comment_exit()

func wants_to_speak():
	if stay_silent:
		return false

	if current_state != CharacterState.SITTING:
		return false

	return speaking_probability > rand_range(0.0, 1.0)

func wants_to_leave():
	if current_state == CharacterState.MOVING:
		return false

	if comfort_limit > comfort:
		return true
	
	if dialogue_max < dialogues_done:
		return true

	return false

func start_speaking():
	if temp_comment_probability < rand_range(0.0, 1.0):
		start_dialogue()
	else:
		comment_temperature()

func start_dialogue():
	if dialogues_done == dialogue_max and comfort >= long_dialogue_comfort:
		current_dialogue = long_dialogue_id
	else:
		if len(has_not_spoken) == 0:
			return

		var random_id = randi() % len(has_not_spoken)
		current_dialogue = has_not_spoken[random_id]
		has_not_spoken.remove(random_id)
	
	dialogues_done += 1
	
	text_id = "0"
	
	create_next_dialogue()

func continue_dialogue():
	if dialogues[current_dialogue][text_id][current_response] == "-1":
		current_dialogue = "-1"
		text_id = "-1"
		start_stay_silent()
		return
	
	text_id = dialogues[current_dialogue][text_id][current_response]
	create_next_dialogue()

func create_next_dialogue():
	print("create new")
	var dialogue_text = dialogues[current_dialogue][text_id]["text"]
	create_speech_bubble(dialogue_text, dialogue_time)
	
	comfort += dialogues[current_dialogue][text_id]["comfort"]
	
	if not dialogues[current_dialogue][text_id]["no_answer"]:
		get_parent().get_parent().start_conversation()
	else:
		current_response = "silent"

func give_response(response):
	current_response = response
	stop_speaking()

func comment_temperature():
	var temp_comment = ""
	
	if get_parent().get_parent().current_temperature < min_temp:
		temp_comment = cold_reactions[cold_reaction_id]
		if cold_reaction_id != 2:
			cold_reaction_id += 1
	elif get_parent().get_parent().current_temperature > max_temp:
		temp_comment = hot_reactions[hot_reaction_id]
		if hot_reaction_id != 2:
			hot_reaction_id += 1
	else:
		temp_comment = normal_reactions[randi() % len(normal_reactions)]

	create_speech_bubble(temp_comment, comment_time)

func comment_exit():
	var exit_comment = ""
	
	if comfort < bad_ending_comfort_limit:
		exit_comment = exit_dialog[0]
	elif comfort > good_ending_comfort_limit:
		exit_comment = exit_dialog[2]
	else:
		exit_comment = exit_dialog[1]
	
	create_speech_bubble(exit_comment, comment_time)

func create_speech_bubble(message, time):
	current_speech_bubble = speech_bubble_scene.instance()
	add_child(current_speech_bubble)
	current_speech_bubble.create_speech_bubble(message)
	
	speaking = true
	$SpeechTimer.start(time)

func stop_stay_silent():
	stay_silent = false

func start_stay_silent():
	$StaySilentTimer.start(stay_silent_time)
	stay_silent = true
	speaking = false

func stop_speaking():
	if current_speech_bubble == null:
		return
	
	if current_dialogue != "-1" and not dialogues[current_dialogue][text_id]["no_answer"]:
		get_parent().get_parent().hide_conversation()
	
	current_speech_bubble.start_fading_bubble()

func destroy_bubble():
	if current_speech_bubble == null:
		return
	
	current_speech_bubble.queue_free()
	current_speech_bubble = null
	
	if current_dialogue != "-1":
		continue_dialogue()
	else:
		start_stay_silent()

func sit_on_bench():
	z_index = 0
	if exiting:
		current_state = CharacterState.NULL
		get_parent().get_parent().character_has_exited(self)
	else:
		position = seat_position
		$AnimatedSprite.animation = "sit"
		current_state = CharacterState.SITTING

func _process(delta):
	if current_state == CharacterState.MOVING:
		var move_vec = (next_position - position)

		if move_vec.length() < walk_speed * delta:
			position = next_position
			sit_on_bench()
		else:
			position += move_vec.normalized() * walk_speed * delta
