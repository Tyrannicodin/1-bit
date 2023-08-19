extends "item_3D.gd"

func focus():
	$mug/base2.set_surface_override_material(0, item_focused_material)
	$mug/wall_1.set_surface_override_material(0, item_focused_material)
	$mug/wall_2.set_surface_override_material(0, item_focused_material)
	$mug/wall_3.set_surface_override_material(0, item_focused_material)
	$mug/wall_4.set_surface_override_material(0, item_focused_material)
	$mug/handle_1.set_surface_override_material(0, item_focused_material)
	$mug/handle_2.set_surface_override_material(0, item_focused_material)
	$mug/handle_3.set_surface_override_material(0, item_focused_material)
	
func unfocus():
	$mug/base2.set_surface_override_material(0, item_material)
	$mug/wall_1.set_surface_override_material(0, item_material)
	$mug/wall_2.set_surface_override_material(0, item_material)
	$mug/wall_3.set_surface_override_material(0, item_material)
	$mug/wall_4.set_surface_override_material(0, item_material)
	$mug/handle_1.set_surface_override_material(0, item_material)
	$mug/handle_2.set_surface_override_material(0, item_material)
	$mug/handle_3.set_surface_override_material(0, item_material)

func can_use():
	return true

func get_texture() -> Texture2D:
	return load("res://assets/items/coffee.png")

func get_item_name() -> String:
	return "COFFEE"

func get_description() -> String:
	return "Coffee: Increase Movement Speed"
