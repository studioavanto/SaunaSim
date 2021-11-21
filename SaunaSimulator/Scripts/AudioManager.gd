extends Node2D

var other_audio = {
	"door_open": preload("res://Sounds/Sauna_ovi_new.wav"),
	"door_close": preload("res://Sounds/Sauna_ovi_new.wav"),
	"sit_down": preload("res://Sounds/Sauna_istahtaminen.wav"),
	"ui_click": preload("res://Sounds/Sauna_Select.wav"),
	"start_game": preload("res://Sounds/Sauna_StartSound.wav")
}

func play_audio(audio_id):
	if audio_id == "character_audio":
		$CharacterAudio.play()
	elif audio_id == "loyly":
		$LoylyAudio.play()
	else:
		$OtherAudio.stop()
		$OtherAudio.stream = other_audio[audio_id]
		$OtherAudio.play()
