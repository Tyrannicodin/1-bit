extends StaticBody3D

var item_material = preload("res://assets/materials/item.tres")
var item_focused_material = preload("res://assets/materials/item_focused.tres")

func _ready():
	add_to_group("ITEM_3D")

# Override these in subclasses
func focus():
	pass

func unfocus():
	pass

func can_use() -> bool:
	return true

func get_texture() -> Texture2D:
	return null

func get_item_name() -> String:
	return ""

func get_description() -> String:
	return ""
