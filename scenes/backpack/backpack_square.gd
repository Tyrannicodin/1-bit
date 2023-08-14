extends Node2D

var hovered: bool = false :
	set(value):
		if value:
			$normal.hide()
			$hovered.show()
		else:
			$normal.show()
			$hovered.hide()
			


# Location that this cell is in the backpack
var x: int
var y: int

func set_location(
	x: int,
	y: int,
	origin: Vector2i,
	cell_size: Vector2i,
):
	print("here")
	self.x = x
	self.y = y
	self.position = Vector2i(origin.x + 32 + cell_size.x * x, origin.y + 32 + cell_size.y * y)
