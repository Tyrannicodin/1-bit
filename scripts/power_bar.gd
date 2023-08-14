extends TextureProgressBar


@onready var this = $"."
@onready var player = $"../../../../../.."
var valueFloat = 100.0
const timeToEmpty = 90

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var change = 1 / (timeToEmpty * 1 / delta) * 100
	valueFloat = float(valueFloat) - change
	
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider_id() == 46087013955:
			valueFloat = valueFloat - 20 * delta
	
	this.value = valueFloat
