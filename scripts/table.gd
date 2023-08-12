extends Node3D


var player: CharacterBody3D = null
var inrange = false
var open = false

@export var range = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_d):
	if not player: # If we didnt't find a player onready, look for one
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return # No need to check range if no player
	
	var distance = player.global_position.distance_squared_to(global_position)
	if distance < range:
		if open:
			$Label.hide()
		else:
			$Label.show()
		inrange = true
	else:
		$Label.hide()
		inrange = false
		if open:
			open = false
			$Animator.play("drawer_animations/animation_drawer_close")

func interact(player):
	if open:
		open = false
		$Animator.play("drawer_animations/animation_drawer_close")
	else:
		open = true
		$Animator.play("drawer_animations/animation_drawer_open")
