extends TextureProgressBar


@onready var this = $"."
@onready var player = $"../../../../../.."
@onready var tick = $"../powerbar_sound"
@onready var ghost = get_tree().get_first_node_in_group("ghost")

signal power_is_zero

var valueFloat = 100.0
var frozen: bool = false
const timeToEmpty = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not ghost:
		ghost = get_tree().get_first_node_in_group("ghost")
		if not ghost:
			return
	
	var change = 1 / (timeToEmpty * 1 / delta) * 100

	if player.VIEW_MODE == player.SPECTRAL:
		change *= 3

	if !frozen:
		valueFloat -= change
	
	if (ghost and ghost.global_position) != null and !frozen:
		var distanceFromGhost = sqrt(pow(player.global_position.x - ghost.global_position.x, 2) + pow(player.global_position.z - ghost.global_position.z, 2))
		if (distanceFromGhost < 4):
			# get variable into range we want 
			distanceFromGhost -= 0.7
			distanceFromGhost = 1 - (distanceFromGhost / 3.3)
			
			# apply easing function
			var easeValue = pow(distanceFromGhost, 3)
			valueFloat -= easeValue * 15 * delta
	
	this.value = valueFloat
	
	if this.value == 0:
		power_is_zero.emit()

## Freeze the power bar for a certain amount of time
func freeze(time: float):
	frozen = true
	var timer = Timer.new()
	timer.set_wait_time(time)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await timer.timeout
	frozen = false
