extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player:CharacterBody3D = null
var first_frame := true
var last_sighting := 0.0
var last_target_reached := 0.0
var idle_target:Node3D = null

## How fast the ghost goes in m/s
@export var speed := 75.0
## The speed decrease (or increase) in idle mode
@export var idle_multiplier := 0.5
var current_speed = speed

@onready var pathfinder := $navigator
@onready var los := $head/ray

func _ready():
	player = get_tree().get_first_node_in_group("player") # Try to get the player

func _physics_process(delta):
	if first_frame:
		first_frame = false
		return
	if not player: # If we didnt't find a player onready, look for one
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return # No need to move if no player found
	
	if player.global_position.distance_to(global_position) < 2:
		if $ghost/AnimationPlayer.current_animation != "animation_ghost_leech":
			$ghost/AnimationPlayer.stop()
			$ghost/AnimationPlayer.play("animation_ghost_leech")
	else:
		if $ghost/AnimationPlayer.current_animation != "animation_ghost_idle":
			$ghost/AnimationPlayer.stop()
			$ghost/AnimationPlayer.play("animation_ghost_idle")
	
	last_sighting += delta
	last_target_reached += delta
	los.look_at(player.global_position)
	if (los.get_collider().name if los.get_collider() else "") == "player":
		last_sighting = 0
	
	var target_position
	if last_sighting < 10:
		current_speed = speed
		target_position = player.global_position
	else:
		current_speed = 0.5*speed
			
		if not idle_target and len(get_tree().get_nodes_in_group("room")) > 0:
			idle_target = get_tree().get_nodes_in_group("room").pick_random()
		var iterations = 0
		while iterations <= 100 and idle_target and idle_target.global_position.distance_to(global_position) < 5:
			iterations += 1
			last_target_reached = 0
			idle_target = get_tree().get_nodes_in_group("room").pick_random()
			if iterations > 100:
				idle_target = null
		if idle_target:
			target_position = idle_target.global_position
		else:
			target_position = player.global_position
	target_position.y = global_position.y
	look_at(target_position)
	pathfinder.target_position = player.global_position
	var next_position = pathfinder.get_next_path_position()
	if pathfinder.is_navigation_finished():
		last_target_reached = 0
		return # Pretty much nothing should happen here:
			# If we're at the player, goal achieved!
			# If we're at a room, we'll be redirected next frame (hopefully)
	# Take the direction the ghost wants to go then multiply by our set speed
	if last_target_reached < 60:
		velocity = position.direction_to(next_position).normalized() * speed * delta
	else:
		velocity = Vector3()
		position = target_position

	move_and_slide()
