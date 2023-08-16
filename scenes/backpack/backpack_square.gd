extends Node2D

var hovered: bool = false :
	set(value):
		if value:
			$normal.hide()
			$hovered.show()
		else:
			$normal.show()
			$hovered.hide()
			

@onready var collision = $Area2D


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
		x_pos +  cell_size.x * self.x - cell_size.x/2., 
		y_pos + cell_size.y * self.y - cell_size.y/2.,
	)

func _on_area_2d_mouse_entered():
	hovered = true


func _on_area_2d_mouse_exited():
	hovered = false
