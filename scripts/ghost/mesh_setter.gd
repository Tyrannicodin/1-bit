extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	set_mesh_layers(self)

func set_mesh_layers(node):
	if node.is_class("MeshInstance3D"):
		node.set_layer_mask_value(1, false)
		node.set_layer_mask_value(2, true)
	else:
		for child in node.get_children():
			set_mesh_layers(child)
