extends Area3D

var on: bool = false

# Called when the node enters the scene tree for the first time.
func toggle():
	if on:
		$"../light".hide()
		on = false
	else:
		on = true
		$"../light".show()
		
