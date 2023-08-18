@tool
extends EditorScript

func _run():
	for child in get_scene().find_children("walls*"):
		for collider in child.get_children():
			collider.queue_free()
		if not child.is_queued_for_deletion():
			child.create_convex_collision(true, true)
