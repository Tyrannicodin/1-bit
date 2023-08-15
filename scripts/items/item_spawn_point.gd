extends Node3D

# Size is the size of item that can be spawned in this location
@export var SIZE = 1

func _ready():
	add_to_group("ITEM_SPAWN_POINT")
	if $MeshInstance3D != null:
		$MeshInstance3D.hide()
