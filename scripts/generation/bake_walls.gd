@tool
extends EditorScript

func _run():
	for child in get_scene().find_children("walls*"):
		child.create_convex_collision(true, true)
