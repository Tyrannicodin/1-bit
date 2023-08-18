extends "item_3D.gd"

func focus():
	$battery.set_surface_override_material(0, item_focused_material)
	
func unfocus():
	$battery.set_surface_override_material(0, item_material)

func get_texture() -> Texture2D:
	return load("res://assets/items/chocolate.png")

func get_item_name() -> String:
	return "CHOCOLATE"

func get_description() -> String:
	return "Chocolate: Pause Battery Draining"
