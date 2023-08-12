extends Label3D


var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not player: # If we didnt't find a player onready, look for one
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return # No need to check range if no player

	look_at(player.global_position, Vector3(0, 1, 0), true)
