extends Node3D

## The size of item that can be spawned in this location
@export var SIZE = 1
## The chance an item will spawn on this spawner. 
@export var SPAWN_CHANCE = 1

@export var RANDOM_X_ROTATION = false
@export var RANDOM_Y_ROTATION = false
@export var RANDOM_Z_ROTATION = false

var rng = RandomNumberGenerator.new()

func _ready():
	add_to_group("ITEM_SPAWN_POINT")
	if $MeshInstance3D != null:
		$MeshInstance3D.hide()

	if rng.randf() < SPAWN_CHANCE:
		spawn_item()

var ITEMS = [
	preload("res://scenes/items/battery.tscn")
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
