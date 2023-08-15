@tool
extends Node3D

func _ready():
	for child in get_children():
		if child.name.contains("walls"):
			child.create_convex_collision(true, true)
