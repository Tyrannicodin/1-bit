extends ReferenceRect

class_name BackpackItem

var BackpackSquare = preload("res://scenes/backpack/backpack_square.gd")

var should_drag = false
var mouse_inside_me = false
var is_in_backpack = false


func _process(_delta):
	# Divide by two because viewport is half the size as the real world.
	var mouse_pos = get_tree().root.get_mouse_position() / 2
	mouse_inside_me = get_rect().has_point(mouse_pos - get_global_transform().origin)

	if Input.is_action_just_pressed("mouse_left_click") and mouse_inside_me:
		should_drag = true

	if not Input.is_action_pressed("mouse_left_click"):
		should_drag = false

	# Item movement
	if should_drag:
		position = get_global_mouse_position()

func enter_backpack(backpack_square: BackpackSquare):
	is_in_backpack = false
	self.position = backpack_square.get_global_transform_with_canvas().origin

func leave_backpack_goodbye():
	is_in_backpack = true
