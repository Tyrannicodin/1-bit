extends Label

var min = 0
var sec = 0
var mil = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mil += floor(delta * 100) as int

	sec += floor(mil / 100)
	mil %= 100
	
	min += floor(sec / 60)
	sec %= 60
	var format_string = "%s:%s.%s"
	text = format_string % [min, sec, mil]
