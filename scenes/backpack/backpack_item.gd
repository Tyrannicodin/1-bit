extends Node2D

var should_drag = false
var mouse_inside_me = false

func _process(_delta):
	if Input.is_action_just_pressed("mouse_left_click") and mouse_inside_me:
		should_drag = true

	if not Input.is_action_pressed("mouse_left_click"):
		should_drag = false


	# Item movement
	if should_drag:
		position = get_global_mouse_position()


func _on_area_2d_mouse_entered():
	mouse_inside_me = true


func _on_area_2d_mouse_exited():
	mouse_inside_me = false
