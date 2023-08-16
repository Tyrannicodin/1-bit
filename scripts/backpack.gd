extends Control

# The backpack is the player's inventory.
# The inventory is a set of cells that the player can store items in.

const Set = preload("res://scripts/util/set.gd")
const Item = preload("res://scripts/item.gd")

const BackpackSquareScene = preload("res://scenes/backpack/backpack_square.tscn")
const BackpackItemScene = preload("res://scenes/backpack/backpack_item.tscn")
const BackpackItem = preload("res://scenes/backpack/backpack_item.gd")


@onready var center = $VBoxContainer/HBoxContainer/Center

# Items is the items the user currently has in thier inventory.
var items = Set.new()

var backpack_squares = {}

# The item the player is holding. Is null if they are not holding an item.
var holding_item: BackpackItem = null

# The amount of cells the backpack has.
@export var BACKPACK_SIZE: Vector2i

const CELL_SIZE = Vector2i(64, 64)

enum {NORTH, SOUTH, EAST, WEST}

# The current rotation of items. This is used to figure out what spaces
# they will take up.
var item_rotation = NORTH

# Rotate the direction of items that are not in the backpaack.
# The item_rotate variable is passed to children in the update function.
func item_rotate():
	if item_rotation == NORTH:
		item_rotation = EAST
	elif item_rotation == EAST:
		item_rotation = SOUTH
	elif item_rotation == SOUTH:
		item_rotation = WEST
	elif item_rotation == WEST:
		item_rotation = NORTH
		
func _init():
	pass

func _ready():
	for i in range(BACKPACK_SIZE.x):
		for j in range(BACKPACK_SIZE.y):
			var backpack_square = BackpackSquareScene.instantiate()
			center.add_child(backpack_square)
			backpack_squares[Vector2i(i, j)] = backpack_square
			backpack_square.set_location(i, j, CELL_SIZE, BACKPACK_SIZE)
			backpack_square.hovered = false

# Open the menu. Pass in all the items the user picked up as an array
# if they have picked any up.
# The menu is shown or hidden by hiding the root node.
func open(add_items: Array[Item]):
	show()

	for item in add_items:
		# TODO: Create backpack item objects of the right size
		# TODO: Not sure where to spawn them in. Probably center right above the backpack.
		pass

# Close the menu. Return the items that the user trashed.
func close() -> Array[Item]:
	hide()
	return []
