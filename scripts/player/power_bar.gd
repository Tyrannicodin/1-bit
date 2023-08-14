extends TextureProgressBar


@onready var player = $"../../../../../.."
var valueFloat = 100.0
const timeToEmpty = 90

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var change = 1 / (timeToEmpty * 1 / delta) * 100
	valueFloat = float(valueFloat) - change
	
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider_id() == 46087013955:
			valueFloat = valueFloat - 20 * delta
	
	value = valueFloat
