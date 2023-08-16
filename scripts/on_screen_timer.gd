extends Label

var minute = 0
var sec = 0
var mil = 0

var count_time = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count_time != true:
		return
	
	mil += floori(delta * 100)

	sec += floori(mil / 100.0)
	mil %= 100
	
	minute += floori(sec / 60.0)
	sec %= 60
	var format_string = "%s:%0*d.%0*d"
	text = format_string % [minute, 2, sec, 2, mil]
	
func time_in_ms(time: Array[int]) -> int:
	return (time[0] * 6000 + time[1] * 100 + time[2]) as int
	
func get_time() -> Array[int]:
	var time = [minute as int, sec as int, mil as int] as Array[int]
	if time_in_ms(time) > time_in_ms(get_best_time()):
		print("sussy")
		save_time(time_in_ms(time))
		
	return time
	
func save_time(score: int):
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(score)
	
func get_best_time() -> Array[int]:
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file == null:
		return [0, 0, 0]
		
	var best_time = save_file.get_32()

	var best_time_min = floori(best_time / 6000.0)
	var best_time_sec = floori(best_time / 100.0) % 60
	var best_time_mil = best_time % 100
		
	return [best_time_min, best_time_sec, best_time_mil]
	
func stop():
	count_time = false
