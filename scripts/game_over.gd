extends Node3D

@onready var time = $SubViewport/VBoxContainer/time
@onready var best_time = $SubViewport/VBoxContainer/best_time

func set_time(game_time: Array[int]) -> void:
	var minute = game_time[0]
	var sec = game_time[1]
	var mil = game_time[2]
	
	var format_string = "%s:%0*d.%0*d"
	time.text = format_string % [minute, 2, sec, 2, mil]

func set_best_time(game_time: Array[int]) -> void:
	var minute = game_time[0]
	var sec = game_time[1]
	var mil = game_time[2]
	
	var format_string = "%s:%0*d.%0*d"
	best_time.text = format_string % [minute, 2, sec, 2, mil]
