extends AudioStreamPlayer


func _input(_e):
	if not playing:
		play()
