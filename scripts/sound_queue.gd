extends Node3D

var next = 0
@export var count = 1
var audioStreamPlayers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() == 0:
		return
	
	var child = get_child(0)
	
	if child is AudioStreamPlayer3D:
		audioStreamPlayers.append(AudioStreamPlayer3D)
		
		for i in count:
			var duplicate = child.duplicate()
			add_child(duplicate)
			audioStreamPlayers.append(duplicate)
			
	print(audioStreamPlayers)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _get_configuration_warnings():
	var warnings = []
	if get_child_count() == 0:
		warnings.append("No children found. Expected one AudioStreamPlayer child.")
	if not get_child(0) is AudioStreamPlayer3D:
		warnings.append("Expected first child to be AudioStreamPlayer")
	return warnings

func play_sound():
	print("played!")
	get_child(0).play()
	#if not audioStreamPlayers[next].playing:
	#	audioStreamPlayers[next].play_sound()
	#	next += 1
	#	next = next % len(audioStreamPlayers)
		
