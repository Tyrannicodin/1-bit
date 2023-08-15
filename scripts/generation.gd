@tool
extends Node2D

# Preload rooms
var room_1 = preload("res://scenes/rooms/room.tscn")
var recursion_depth = 3

func generate_new_branch(base_room: Node):
	for node in base_room.get_children():
		if node.name.contains("door"):
			var door = node
			
			# Create new room depending on direction. Right now I pick the same room every time
			var new_room = room_1.instantiate()
			
			var floor = new_room.get_child(0)
			
			# get position from origin of door
			var door_position = {
				"x" : door.position.x,
				"z" : door.position.z
			}
			
			# get the size of the room we are generating
			var this_room_size = {
				"x" : floor.mesh.size[0],
				"z" : floor.mesh.size[1]
			}
			
			# set new position
			new_room.position.x = new_room.position.x + door_position.x
			new_room.position.z = new_room.position.z + door_position.z
			
			# offset room properly depending on where it generates (this might not work but I think it does)
			if (new_room.position.x > base_room.position.x):
				new_room.position.x = new_room.position.x + this_room_size.x / 2
			elif (new_room.position.x < base_room.position.x):
				new_room.position.x = new_room.position.x - this_room_size.x / 2
			elif (new_room.position.z > base_room.position.z):
				new_room.position.z = new_room.position.z + this_room_size.z / 2
			elif (new_room.position.z < base_room.position.z):
				new_room.position.z = new_room.position.z - this_room_size.z / 2
			base_room.add_child(new_room)
	# output for next level of recursion
	return base_room.get_children()
	
func generate_branches(new_nodes: Array[Node], depth: int):
	if depth == 0:
		return
	for node in new_nodes:
		generate_branches(generate_new_branch(node), depth-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	# First create a base child
	var base_room = room_1.instantiate() 
	add_child(base_room)
	
	for i in range (0,recursion_depth):
		var new_nodes = generate_new_branch(base_room)
		generate_branches(new_nodes, 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
