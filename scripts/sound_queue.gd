extends Node2D

var count = 0
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	count = get_child_count()

func play():
	get_child(rng.randi_range(0, count-1)).play()
	#if not audioStreamPlayers[next].playing:
	#	audioStreamPlayers[next].play_sound()
	#	next += 1
	#	next = next % len(audioStreamPlayers)
		
