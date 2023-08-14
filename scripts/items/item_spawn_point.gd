extends Node3D

# Size is the size of item that can be spawned in this location
@export var SIZE = 1

func _ready():
	add_to_group("ITEM_SPAWN_POINT")
	$MeshInstance3D.hide()
