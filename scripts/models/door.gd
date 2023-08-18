extends Node3D

var can_interact = true
var open = true

@onready var meshes = [$default, $boarded, $entrance]

func hide_meshes():
	for mesh in meshes:
		mesh.hide()
		mesh.position.y = -3

func _process(_d):
	hide_meshes()
	if get_meta("entrance", false):
		$entrance.show()
		$entrance.position.y = 0
	elif get_meta("boarded", false):
		$boarded.show()
		$boarded.position.y = -1
	else:
		$default.show()
		$default.position.y = -1

func toggle_open():
	if get_meta("entrance", false) or get_meta("boarded", false):
		return
	if not can_interact:
		return
	if open:
		$default/AnimationPlayer.play("animation_door_close")
		$door_close_sound.play()
		open = false
		can_interact = false
		await $default/AnimationPlayer.animation_finished
		can_interact = true
	else:
		$default/AnimationPlayer.play("animation_door_open")
		$door_opening_sound.play()
		open = true
		can_interact = false
		await $default/AnimationPlayer.animation_finished
		can_interact = true
