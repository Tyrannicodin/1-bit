extends TextureRect

@onready var this = $"."


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	this.size = get_window().size
	set_size(get_window().size)
