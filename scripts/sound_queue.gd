extends Node2D

var count = 0
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	count = get_child_count()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play():
	get_child(rng.randf_range(0, count)).play()
	#if not audioStreamPlayers[next].playing:
	#	audioStreamPlayers[next].play_sound()
	#	next += 1
	#	next = next % len(audioStreamPlayers)
		
