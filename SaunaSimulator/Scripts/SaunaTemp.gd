extends Node2D

func set_temperature(temp):
	$TempPointer.rotation_degrees = - 45 + temp * 90
