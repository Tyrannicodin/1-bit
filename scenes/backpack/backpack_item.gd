extends ReferenceRect

class_name BackpackItem

var BackpackSquare = preload("res://scenes/backpack/backpack_square.gd")

@onready var texture = $ItemTexture
var item_texture: Texture2D = null

var should_drag = false
var mouse_inside_me = false
var is_in_backpack = false

func _ready():
	texture.set_texture(item_texture)
	add_to_group("BACKPACK_ITEM")

func set_texture(item_texture_):
	item_texture = item_texture_

func _process(_delta):
	# im sorry god
	# please nobody touch this
	
	# Divide by two because viewport is half the size as the real world.
	var mouse_pos = get_tree().root.get_mouse_position() / 2
	mouse_inside_me = (mouse_pos - get_global_position()).distance_to(Vector2(16, 16)) < 16

	if Input.is_action_just_pressed("mouse_left_click") and mouse_inside_me:
		should_drag = true

	if not Input.is_action_pressed("mouse_left_click"):
		should_drag = false

	# Item movement
	if should_drag:
		position = get_tree().root.get_mouse_position() / 2- Vector2(16, 16)

func enter_backpack(backpack_square: BackpackSquare):
	is_in_backpack = true
	self.position = backpack_square.get_global_transform_with_canvas().origin - Vector2(16, 16)

func leave_backpack_goodbye():
	is_in_backpack = false
