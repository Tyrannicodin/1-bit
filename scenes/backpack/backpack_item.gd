extends ReferenceRect

class_name BackpackItem

var BackpackSquare = preload("res://scenes/backpack/backpack_square.gd")

signal use_item
signal hovered

static var holding_item = false
static var freed_item = false
static var biggest_z_index = 0

@onready var texture = $ItemTexture

var should_drag = false
var mouse_inside_me = false
var is_in_backpack = false
var backpack_square = null

var item_name: String = ""
var item_texture: Texture2D = null
var can_use: bool = true
var description: String = ""

func _ready():
	process_priority = 1
	set_z_index_sub()
	texture.set_texture(item_texture)
	add_to_group("BACKPACK_ITEM")

func init(item_texture_, item_name_, can_use_, description_):
	item_texture = item_texture_
	item_name = item_name_
	can_use = can_use_
	description = description_

	add_to_group(item_name)

func set_z_index_sub():
	biggest_z_index += 1
	z_index = biggest_z_index

func _process(_delta):
	check_hovered()
	check_used()

	await get_tree().process_frame
	
	freed_item = false

func check_hovered():
	# im sorry god
	# please nobody touch this
	
	# Divide by two because viewport is half the size as the real world.
	var mouse_pos = get_tree().root.get_mouse_position() / 2
	mouse_inside_me = (mouse_pos - get_global_position()).distance_to(Vector2(16, 16)) < 16

	if mouse_inside_me:
		hovered.emit(description)

	if Input.is_action_just_pressed("mouse_left_click") and mouse_inside_me and !holding_item:
		should_drag = true
		holding_item = true

	if not Input.is_action_pressed("mouse_left_click"):
		should_drag = false

	# Item movement
	if should_drag:
		position = get_tree().root.get_mouse_position() / 2- Vector2(16, 16)

	if Input.is_action_just_released("mouse_left_click"):
		holding_item = false

func check_used():
	if !can_use:
		freed_item = true
		return false
	
	if freed_item:
		return

	if not Input.is_action_just_pressed("interact"):
		return

	if not mouse_inside_me:
		return

	freed_item = true

	use_item.emit(item_name)

	delete()

func enter_backpack(backpack_square_: BackpackSquare):
	is_in_backpack = true
	backpack_square = backpack_square_
	self.position = backpack_square.get_global_transform_with_canvas().origin - Vector2(16, 16)
	process_priority = 5
	z_index = 0

func delete():
	if backpack_square != null:
		backpack_square.clear_item()

	self.queue_free()

func leave_backpack_goodbye():
	backpack_square = null
	is_in_backpack = false
	process_priority = 1
	set_z_index_sub()
