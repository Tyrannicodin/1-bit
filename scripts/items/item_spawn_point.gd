extends Node3D

## The size of item that can be spawned in this location
@export var SIZE = 1
## The chance an item will spawn on this spawner. 
@export var SPAWN_CHANCE: float = .2

## Give the item a random rotation around the x axis when spawned.
@export var RANDOM_X_ROTATION = false
## Give the item a random rotation around the y axis when spawned.
@export var RANDOM_Y_ROTATION = false
## Give the item a random rotation around the z axis when spawned.
@export var RANDOM_Z_ROTATION = false

var rng = RandomNumberGenerator.new()

func _ready():
	add_to_group("ITEM_SPAWN_POINT")
	if has_node("MeshInstance3D"):
		$MeshInstance3D.hide()

	if rng.randf() < SPAWN_CHANCE:
		spawn_item()

var ITEMS = [
	preload("res://scenes/items/battery.tscn"),
	preload("res://scenes/items/chocolate.tscn"),
]

func spawn_item():
	var item = ITEMS[rng.randi_range(0, len(ITEMS) - 1)].instantiate()

	if RANDOM_X_ROTATION:
		item.rotation.x = rng.randf()
	if RANDOM_Y_ROTATION:
		item.rotation.y = rng.randf()
	if RANDOM_Z_ROTATION:
		item.rotation.z = rng.randf()

	add_child(item)
