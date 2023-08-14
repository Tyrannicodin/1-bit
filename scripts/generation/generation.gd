extends Node


class wave_grid:
	const OPPOSING_SIDES = {
		"up": "down",
		"down": "up",
		"left": "right",
		"right": "left",
	}
	
	var grid:Array = []
	var available_squares:Array
	var generator:RandomNumberGenerator
	var size:Vector2i
	
	func _init(grid_size:Vector2i, entrance_location:Vector2i, squares:String, entrances:String, genseed:int = -1):
		# This is the generator we use for our collapse function
		generator = RandomNumberGenerator.new()
		if genseed > 0:
			generator.seed = genseed
		size = grid_size
		
		# Load the list of squares and entrances
		var square_file = FileAccess.open(squares, FileAccess.READ)
		available_squares = JSON.parse_string(square_file.get_as_text())
		square_file.close()
		
		var entrance_file = FileAccess.open(entrances, FileAccess.READ)
		var entrance_json = JSON.parse_string(entrance_file.get_as_text())
		entrance_file.close()
		
		for y in size.y:
			grid.append([])
			for x in size.x:
				grid[y].append(available_squares)
		var entrance = random_choice(entrance_json)
		for part in len(entrance):
			grid[entrance_location.y-part][entrance_location.x] = [entrance[part]]
	
	func random_choice(options:Array):
		"""Gets a random item from an array"""
		return options[generator.randi_range(0, len(options)-1)]
	
	func lowest_entropy():
		"""Find the cell with lowest number of possible positions"""
		var minimum_entropy = INF
		var options = []
		var cell_options
		for y in size.y:
			for x in size.x:
				cell_options = get_options(Vector2i(x, y))
				if len(cell_options) < 1: # Ignore if 100% sure what it ts
					continue
				if len(cell_options) == minimum_entropy: # If equal to current min, add to list
					options.append(Vector2i(x, y))
				elif len(cell_options) < minimum_entropy: # If less than current min, make it current min
					minimum_entropy = len(cell_options)
					options = [Vector2i(x, y)]
	
	func get_options(coord:Vector2i):
		"""Gets all posible tiles a coordinate could become"""
		var target = grid[coord.y][coord.x]
		var previous_options
		
		if coord.y > 0:
			var choices = grid[coord.y-1][coord.x]
			previous_options = check_connections(target, choices, "up", available_squares)
		else:
			previous_options = check_wall(target, "up", available_squares)
		
		if coord.x < size.x-1:
			var choices = grid[coord.y][coord.x+1]
			previous_options = check_connections(target, choices, "right", previous_options)
		else:
			previous_options = check_wall(target, "right", previous_options)
		
		if coord.y < size.y-1:
			var choices = grid[coord.y+1][coord.x]
			previous_options = check_connections(target, choices, "down", previous_options)
		else:
			previous_options = check_wall(target, "down", previous_options)
		
		if coord.x > 0:
			var choices = grid[coord.y][coord.x-1]
			previous_options = check_connections(target, choices, "left", previous_options)
		else:
			previous_options = check_wall(target, "left", previous_options)
		
		return previous_options
	
	func check_connections(target, choices, side, previous_options):
		"""Check if a target can connect with another and decide if it is valid to place"""
		var final_options = []
		for option in target:
			for choice in choices:
				if valid_connection(option, choice, side) and option in previous_options:
					final_options.append(option)
					break
		return final_options
	
	func check_wall(target, side, previous_options):
		"""Check if a target has a wall to block the outside"""
		var final_options = []
		for option in target:
			if option[side] == "w" and option in previous_options:
				final_options.append(option)
		return final_options
	
	func valid_connection(option, choice, side:String):
		"""Check if two sides are valid to connect with"""
		var target_node:String = option[side]
		var chosen_node:String = choice[OPPOSING_SIDES[side]]
		#if chosen_node.begins_with("i_"):
		#	return (option["id"] == chosen_node.trim_prefix("i_")
		#		and target_node.trim_prefix("i_") == choice["id"])
		if chosen_node.begins_with("w"):
			return target_node.begins_with("w")
		elif chosen_node.begins_with("d"):
			return target_node.begins_with("d")
		else:
			return false
	
	"""func lowest_entropy():
		var minimum_entropy = INF
		var options = []
		var cell
		for a in size: # Y iterator
			for b in size: # X iterator
				cell = grid[a][b]
				if len(cell) <= 1: # Ignore if already singled out
					continue
				elif len(cell) == minimum_entropy: # Add to options if equal to minimum entropy
					options.append(cell)
				elif len(cell) < minimum_entropy: # If lower entropy make it the new options
					minimum_entropy = len(cell)
					options = [cell]
		return options
	
	func place(coord:Vector2i):
		# Select a random cell from available options
		var options = grid[coord.y][coord.x]
		var chosen = options[generator.randi_range(0, len(options)-1)]
		grid[coord.y][coord.x] = [chosen]
		reduce_surroundings(coord, [coord]) # Reduce anything nearby
	
	func reduce_surroundings(coord:Vector2i, excluded_positions:Array[Vector2i] = []):
		var options = grid[coord.y][coord.x]
		
		if coord.y > 0 and not Vector2i(coord.x, coord.y-1) in excluded_positions:
			reduce_square(options, "up", Vector2i(coord.x, coord.y-1), excluded_positions)
		
		if coord.y < size-1 and not Vector2i(coord.x, coord.y+1) in excluded_positions:
			reduce_square(options, "down", Vector2i(coord.x, coord.y+1), excluded_positions)
		
		if coord.x > 0 and not Vector2i(coord.x-1, coord.y) in excluded_positions:
			reduce_square(options, "left", Vector2i(coord.x-1, coord.y), excluded_positions)
		
		if coord.x < size-1 and not Vector2i(coord.x+1, coord.y) in excluded_positions:
			reduce_square(options, "right", Vector2i(coord.x+1, coord.y), excluded_positions)
	
	func reduce_square(chosen:Array, side:String, coord:Vector2i, excluded_positions:Array[Vector2i] = []):
		var final_options = []
		for option in grid[coord.y][coord.x]:
			for choice in chosen:
				if valid_choice(option, choice, side):
					final_options.append(option)
					break
		grid[coord.y][coord.x] = final_options
		# After a cell has been reduced, we reduce the cells nearby in order to propagate to every
		# Cell
		excluded_positions.append(coord)
		reduce_surroundings(coord, excluded_positions)"""
	
	

func _ready():
	var world = wave_grid.new(
		Vector2i(4, 4),
		Vector2i(0, 3),
		"res://assets/grid_data/squares.json",
		"res://assets/grid_data/entrances.json",
	)
	print(world.lowest_entropy())
	print(world.grid)
