extends Node2D

class_name BackpackSquare

var BackpackItem = preload("res://scenes/backpack/backpack_item.gd")

var current_item: BackpackItem = null

var hovered: bool = false

# Location that this cell is in the backpack
var x: int
var y: int

func set_location(
	new_x: int,
	new_y: int,
	cell_size: Vector2i,
	grid_size: Vector2i,
):
	self.x = new_x
	self.y = new_y

	var x_pos = float(new_x) - float(grid_size.x) / 2.
	var y_pos = float(new_y) - float(grid_size.y) / 2.

	self.transform.origin = Vector2(
		x_pos + cell_size.x * (self.x - .5), 
		y_pos + cell_size.y * (self.y - .5), 
	)

func _process(_delta):
	# Divide by two because viewport is half the size as the real world.
	var mouse_pos = get_tree().root.get_mouse_position() / 2
	hovered = $Rect.get_rect().has_point(mouse_pos - get_global_transform().origin)

	check_pickup_item()

func check_pickup_item():
	if not (Input.is_action_just_released("mouse_left_click") and hovered):
		return

	if current_item != null:
		return

	var bodies = $Area2D.get_overlapping_areas()
	if len(bodies) < 1:
		return
	var body = bodies[0].get_node("..")
	body.enter_backpack(self)
	current_item = body


func _on_area_2d_area_exited(area):
	if area.get_node("..") == current_item:
		clear_item()

func clear_item():
	current_item.leave_backpack_goodbye()
	current_item = null
