extends Node3D

@export var recursion_depth = 1

var generator = RandomNumberGenerator.new()
var rooms = {}
var category_info = {}
var entrance = []
var end = []

func random_choice(array:Array):
	var idx = generator.randi_range(0, len(array)-1)
	return array[idx]

func pick_room():
	var total_chance = 0
	var chances = []
	# Iterate through the categorys and record what number they are selected at
	var categorys = category_info.keys()
	categorys.sort()
	for category in categorys:
		if len(rooms[category]) > 0:
			chances.append([category, total_chance])
			total_chance += category_info[category]
	var selected_idx = generator.randf_range(0, total_chance)
	var selected_cat
	for chance in chances:
		# Find the first category that is less than the chosen probability and select it
		if chance[1] < selected_idx:
			selected_cat = chance[0]
			break
	if selected_cat:
		return random_choice(rooms[selected_cat])
	return random_choice(end) # If no valid room from category, end this path

func load_rooms():
	var json_file = FileAccess.open("res://scenes/rooms/category_info.json", FileAccess.READ)
	category_info = JSON.parse_string(json_file.get_as_text())
	var roomdir = DirAccess.open("res://scenes/rooms")
	for category in roomdir.get_directories(): # Iterate through folders, these will be our catgeories
		rooms[category] = []
		for file in DirAccess.get_files_at("res://scenes/rooms/" + category):
			if file.ends_with(".tscn"): # Assume all scene files are rooms
				rooms[category].append(load("res://scenes/rooms/" + category + "/" + file))
	entrance = rooms["entrance"]
	rooms.erase("entrance")
	end = rooms["end"]
	rooms.erase("end")

func generate_new_branch(base_room: Node):
	for node in base_room.get_children():
		if node.name.contains("door"):
			if node.get_meta("connected", false): # Ignore door if it has connection
				continue
			
			var door = node
			
			# Create new room depending on direction. Right now I pick the same room every time
			var new_room = pick_room().instantiate()
			base_room.add_child(new_room)
			
			var new_room_doors = []
			for child in new_room.get_children():
				if child.name.contains("door"):
					new_room_doors.append(child)
			var new_chosen_door = random_choice(new_room_doors)
			new_chosen_door.set_meta("connected", true)
			
			# get position from origin of door
			var door_position = Vector2(door.global_position.x, door.global_position.z)
			var door_rotation = door.global_rotation.y + new_chosen_door.rotation.y
			
			# rotate the room to meet with the door
			new_room.global_rotation = Vector3.UP * -door_rotation
			
			var new_door_position = new_chosen_door.position.rotated(Vector3.UP, -door_rotation)
			
			# set position so it the two door touches
			new_room.global_position.x = door_position.x - new_door_position.x
			new_room.global_position.z = door_position.y - new_door_position.z
			
			# delete door so only the new one remains
			door.queue_free()
	# output for next level of recursion
	return base_room.get_children()
	
func generate_branches(new_nodes: Array[Node], depth: int):
	if depth == 0:
		return
	for node in new_nodes:
		generate_branches(generate_new_branch(node), depth-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	generator.seed = 0
	
	load_rooms()
	
	# First create a base child
	var base_room = random_choice(entrance).instantiate()
	add_child(base_room)
	
	for i in recursion_depth:
		var new_nodes = generate_new_branch(base_room)
		generate_branches(new_nodes, recursion_depth-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
