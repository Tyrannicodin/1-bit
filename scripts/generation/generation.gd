extends Node3D

@export var recursion_depth := 32

@onready var mesh_template = $MeshInstance3D

var generator := RandomNumberGenerator.new()
var rooms := {}
var category_info := {}
var entrance:Array = []
var end:Array = []
var room_boundings:Array[AABB] = []

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
			if file.contains(".tscn"): # Assume all scene files are rooms
				file = file.trim_suffix(".remap")
				rooms[category].append(ResourceLoader.load("res://scenes/rooms/" + category + "/" + file, "PackedScene"))
	entrance = rooms["entrance"]
	rooms.erase("entrance")
	end = rooms["end"]
	rooms.erase("end")

func create_ceiling_and_walls(new_room, new_area):
	var ceiling_mesh:MeshInstance3D = mesh_template.duplicate()
	new_room.add_child(ceiling_mesh)
	ceiling_mesh.global_position.x = new_area.global_position.x
	ceiling_mesh.global_position.y = 3
	ceiling_mesh.global_position.z = new_area.global_position.z
	ceiling_mesh.scale.x = new_area.shape.size.x
	ceiling_mesh.scale.z = new_area.shape.size.z
	ceiling_mesh.scale.y = 0.1
	if (ceiling_mesh != null):
		ceiling_mesh.visible = true

func try_place_room(door:Node3D, new_door:Node3D, new_room:Node3D):	
	# find the required rotation of the room
	var door_rotation = door.global_rotation.y - new_door.global_rotation.y - PI

	new_room.global_position = Vector3(0, 0, 0)
	new_room.global_rotate(Vector3.UP, door_rotation)
	new_room.global_rotation_degrees.y = snapped(new_room.global_rotation_degrees.y, 1)
	# set position so it the two door touches
	new_room.global_position.x = snapped(door.global_position.x - new_door.global_position.x, 0.001)
	new_room.global_position.z = snapped(door.global_position.z - new_door.global_position.z, 0.001)

	# Create room bounding
	var new_boundings = []
	var area_shape
	for new_area in new_room.get_node("area").get_children():
		area_shape = new_area.shape.size
		if not (100 > abs(new_area.global_rotation_degrees.y) and abs(new_area.global_rotation_degrees.y) > 80):
			var x_swapping = area_shape.x
			area_shape.x = area_shape.z
			area_shape.z = x_swapping
		new_boundings.append(AABB(new_area.global_position, area_shape))
		# Create ceiling
		create_ceiling_and_walls(new_room, new_area)
	for bounding in new_boundings:
		for room in room_boundings:
			if bounding.intersects(room):
				new_room.queue_free()
				return false
	new_room.add_to_group("room")
	room_boundings.append_array(new_boundings)
	door.queue_free()
	return true

func place_end(door):
	var room_parent = door.get_parent()
	
	var available_rooms = end.duplicate()
	var new_packed_scene = random_choice(end)
	available_rooms.erase(new_packed_scene)
	var new_room = new_packed_scene.instantiate()
	room_parent.add_child(new_room)
	var placed = try_place_room(door, new_room.get_node("door"), new_room)
	while not placed:
		new_room.queue_free()
		if len(available_rooms) == 0:
			return false
		new_packed_scene = random_choice(end)
		available_rooms.erase(new_packed_scene)
		new_room = new_packed_scene.instantiate()
		room_parent.add_child(new_room)
		placed = try_place_room(door, new_room.get_node("door"), new_room)
	door.queue_free()
	new_room.get_node("door").set_meta("connected", true)
	return true

func generate_new_branch(base_room: Node3D):
	var next_recursion:Array[Node] = []
	for node in base_room.get_children():
		if node.name.contains("door"):
			if node.get_meta("connected", false) or node.is_queued_for_deletion(): # Ignore door if it has connection
				continue
			
			var door = node
			
			# Create new room depending on direction. Right now I pick the same room every time
			var new_room = pick_room().instantiate()
			base_room.add_child(new_room)
			
			# Pick a random door in the new room to attach to
			var new_room_doors = []
			for child in new_room.get_children():
				if child.name.contains("door"):
					new_room_doors.append(child)
			var new_chosen_door = random_choice(new_room_doors)
			
			var placed = try_place_room(door, new_chosen_door, new_room)
			while not placed:
				new_room_doors.erase(new_chosen_door)
				if len(new_room_doors) == 0:
					new_room.queue_free()
					if not place_end(door):
						door.set_meta("boarded", true)
					break
				new_chosen_door = random_choice(new_room_doors)
				placed = try_place_room(door, new_chosen_door, new_room)
			# delete door so only the new one remains
			if not new_room.is_queued_for_deletion():
				new_chosen_door.set_meta("connected", true)
				next_recursion.append(new_room)
				if ghost_pos.distance_to(Vector3(0,0,0)) < new_room.global_position.distance_to(Vector3(0,0,0)):
					ghost_pos = new_room.global_position
				door.queue_free()
	# output for next level of recursion
	return next_recursion
	
func generate_branches(new_nodes: Array[Node], depth: int):
	if len(new_nodes) == 0:
		print(depth)
		return
	if depth == 0:
		for node in new_nodes:
			for door in node.get_children():
				if "door" in door.name:
					place_end(door)
		return
	for node in new_nodes:
		generate_branches(generate_new_branch(node), depth-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(generator.seed)

	load_rooms()

	# First create a base child
	var base_room = random_choice(entrance).instantiate()
	add_child(base_room)
	var base_area:CollisionShape3D = base_room.get_node("area").get_child(0)
	var base_aabb = AABB(base_room.global_position, base_area.shape.size)
	room_boundings.append(base_aabb)

	create_ceiling_and_walls(base_room, base_area)

	var new_nodes = generate_new_branch(base_room)
	generate_branches(new_nodes, recursion_depth-1)

var frames := 0
var ghost_pos:Vector3

func _process(_d):
	frames += 1
	if frames == 10:
		var ghost = get_tree().get_first_node_in_group("ghost")
		if ghost:
			ghost_pos.y = 1
			ghost.position = ghost_pos
		set_process(false)
