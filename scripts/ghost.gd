extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player:CharacterBody3D = null

@export var speed = 2.5

@onready var pathfinder = $Navigator

func _ready():
	player = get_tree().get_first_node_in_group("player") # Get the player

func _physics_process(_d):
	if not player: # If we didnt't find a player onready, look for one
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return # No need to move if no player found
	
	pathfinder.target_position = player.position
	var next_position = pathfinder.get_next_path_position()
	if pathfinder.is_navigation_finished() or not pathfinder.is_target_reachable():
		return # TODO: Add idle behaviour
	# Take the direction the ghost wants to go then multiply by our set speed
	velocity = position.direction_to(next_position).normalized() * speed

	move_and_slide()
