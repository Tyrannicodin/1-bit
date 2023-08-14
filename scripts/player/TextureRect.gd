extends TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_d):
	size = get_window().size
	set_size(get_window().size)
