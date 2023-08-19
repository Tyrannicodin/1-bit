extends "item_3D.gd"


func focus():
	$battery.set_surface_override_material(0, item_focused_material)
	$battery2.set_surface_override_material(0, item_focused_material)
	$battery3.set_surface_override_material(0, item_focused_material)
	
func unfocus():
	$battery.set_surface_override_material(0, item_material)
	$battery2.set_surface_override_material(0, item_material)
	$battery3.set_surface_override_material(0, item_material)

func can_use() -> bool:
	return true

func get_texture() -> Texture2D:
	return load("res://assets/items/battery.png")

func get_item_name() -> String:
	return "BATTERY"

func get_description() -> String:
	return "Battery: Keep your flashlight alive."
