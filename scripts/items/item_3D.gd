extends StaticBody3D

var item_material = preload("res://assets/materials/item.tres")
var item_focused_material = preload("res://assets/materials/item_focused.tres")

func _ready():
	add_to_group("ITEM_3D")

# NOTE: Make this more generic
func focus():
	$battery.set_surface_override_material(0, item_focused_material)

func unfocus():
	$battery.set_surface_override_material(0, item_material)


func get_texture() -> Texture2D:
	return load("res://assets/items/battery.png")

func get_item_name() -> String:
	return "BATTERY"
