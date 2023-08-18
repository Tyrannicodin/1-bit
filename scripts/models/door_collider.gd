extends Node3D

@export var levels := 5

var parent_door

func _ready():
	parent_door = self
	for i in levels:
		parent_door = parent_door.get_parent()
