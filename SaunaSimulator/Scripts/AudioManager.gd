extends Node2D

var other_audio = {
	"door_open": preload("res://Sounds/Sauna_ovi.wav"),
	"door_close": preload("res://Sounds/Sauna_ovi.wav"),
	"sit_down": preload("res://Sounds/Sauna_istahtaminen.wav"),
	"ui_click": preload("res://Sounds/loyl.wav")
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
