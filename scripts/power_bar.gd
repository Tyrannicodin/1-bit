extends TextureProgressBar


@onready var this = $"."
@onready var player = $"../../../../../.."
@onready var timer = $"../powerbar_sound_timer"
@onready var tick = $"../powerbar_sound"
@onready var ghost = get_tree().get_nodes_in_group("ghost")[0]

var valueFloat = 100.0
const timeToEmpty = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var change = 1 / (timeToEmpty * 1 / delta) * 100

	if player.VIEW_MODE == "spectral":
		change *= 3
	
	valueFloat -= change
	
	if (ghost and ghost.global_position) != null:
		var distanceFromGhost = sqrt(pow(player.global_position.x - ghost.global_position.x, 2) + pow(player.global_position.z - ghost.global_position.z, 2))
		if (distanceFromGhost < 4):
			# get variable into range we want
			distanceFromGhost -= 0.7
			distanceFromGhost = 1 - (distanceFromGhost / 3.3)
			
			# apply easing function
			var easeValue = pow(distanceFromGhost, 3)
			valueFloat -= easeValue * 15 * delta
	
	this.value = valueFloat
