extends Node3D

@onready var meshes = [$default, $boarded, $entrance]

func hide_meshes():
	for mesh in meshes:
		mesh.hide()

func _process(_d):
	hide_meshes()
	if get_meta("entrance", false):
		$entrance.show()
	elif get_meta("boarded", false):
		$boarded.show()
	else:
		$default.show()
