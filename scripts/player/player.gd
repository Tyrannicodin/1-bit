extends CharacterBody3D

enum {FLASHLIGHT, SPECTRAL}

@export var VIEW_MODE := FLASHLIGHT
@export var END_GAME_WHEN_OUT_OF_POWER := true
@export var SPEED := 150
@export var FAST_SPEED := 225

var current_speed = SPEED

@onready var camera = $"cameraLoc"
@onready var ghostCamera = $"ghostCameraLoc"
@onready var ghostViewport = $GameContainer/GameViewport/GhostViewportContainer
@onready var spectralView = $GameContainer/GameViewport/MainViewportContainer/MainViewport/SpectralView
@onready var flashlightView = $GameContainer/GameViewport/MainViewportContainer/MainViewport/FlashlightView
@onready var flashlight_shader = flashlightView.get_node("ColorRect")
@onready var spectralViewDither = $GameContainer/GameViewport/GhostViewportContainer/SpectralFilter
@onready var spectral_dither_shader = spectralViewDither.get_node("ColorRect")
@onready var flashlight = $GameContainer/GameViewport/MainViewportContainer/MainViewport/Camera/Torch
@onready var radar = $GameContainer/GameViewport/MainViewportContainer/MainViewport/Camera/RadarLight
@onready var tooltipButton = $GameContainer/GameViewport/UIViewport/Tooltip/Button
@onready var tooltipLabel = $GameContainer/GameViewport/UIViewport/Tooltip/Label
@onready var flashlightSelected = $GameContainer/GameViewport/UIViewport/VBoxContainer/Mainhand/FlashlightBox/SelectedSlot
@onready var radarSelected = $GameContainer/GameViewport/UIViewport/VBoxContainer/Mainhand/RadarBox/SelectedSlot
@onready var UI = $UIRect
@onready var raycast3d = $cameraLoc/RayCast3D
@onready var backpack = $GameContainer/GameViewport/UIViewport/backpack

# Sound
@onready var sound_flashlight = $GameContainer/GameViewport/sound_flashlight
@onready var sound_radar = $GameContainer/GameViewport/sound_radar
@onready var sound_radar_off = $GameContainer/GameViewport/sound_radar_off
@onready var sound_radar_loop = $GameContainer/GameViewport/sound_radar_loop

@onready var footsteps = $GameContainer/GameViewport/footsteps_master
@onready var footsteps_timer = $GameContainer/GameViewport/footsteps_timer

# To make cycling easier
@onready var spectral_view_visible = [spectralView, spectralViewDither, radar, ghostViewport, radarSelected]
@onready var flashlight_view_visible = [flashlightView, flashlight, flashlightSelected]

# Power bar/game over
@onready var power = $"GameContainer/GameViewport/UIViewport/VBoxContainer/Power Bar/ProgressBar"
@onready var gos = $"Game over"
@onready var gos_viewport = gos.get_child(0).get_child(0)
@onready var game_timer = $GameContainer/GameViewport/UIViewport/VBoxContainer2/Label
var is_game_over = false

var mouse_captured = false
var flashes = true
var available_interactions = []
var death_palette:float = 0

var flashlight_palette = preload("res://assets/shaders/dithering/palette_1.png")
var spectral_dither_palette = preload("res://assets/shaders/dithering/palette_2.png")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# The node that the player is looking at.
var focusing_node = null


func _ready():
	"""Setup for game"""
	mouse_captured = true # Capture the mouse and remember it for later
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	power.power_is_zero.connect(death)
	backpack.use_item.connect(_on_use_item)
	backpack.backpack_close.connect(close_backpack)
	gos_viewport.visible = false

func _input(event):
	"""Handle mouse movement"""
	if event is InputEventMouseMotion:
		if mouse_captured: # If the mouse is captured and gets moved, rotate the camera
			rotate(Vector3(0, 1, 0), -event.relative.x * 0.001)
			camera.rotate(Vector3(1, 0, 0), -event.relative.y * 0.001)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 60)
			ghostCamera.rotate(Vector3(1, 0, 0), -event.relative.y * 0.001)
			ghostCamera.rotation_degrees.x = clamp(ghostCamera.rotation_degrees.x, -80, 60)

func _process(_d):
	# death
	if power.value == 0:
		death()
	
	if power.value <= 10 and power.value > 0 and flashes:
		if int(death_palette) == death_palette:
			var palette_path = "res://assets/shaders/dithering/death/palette_"+str(death_palette)+".png"
			if not FileAccess.file_exists(palette_path):
				death_palette = 0
				palette_path = "res://assets/shaders/dithering/death/palette_"+str(death_palette)+".png"
			var palette = load(palette_path)
			flashlight_shader.material.set_shader_parameter("u_color_tex", palette)
			spectral_dither_shader.material.set_shader_parameter("u_color_tex", palette)
		death_palette += 0.5
	else:
		flashlight_shader.material.set_shader_parameter("u_color_tex", flashlight_palette)
		spectral_dither_shader.material.set_shader_parameter("u_color_tex", spectral_dither_palette)

#	if power.value <= 30:
#		var batteries = backpack.get_tree().get_nodes_in_group("BATTERY")
#		if len(batteries) >= 1:
#			var first = batteries.pop_front()
#			first.delete()
#			power.valueFloat += 50
		

func _physics_process(delta):
	"""Make sure that we don't run when the player lost"""
	if is_game_over == true:
		return
	
	"""Handle the player's input and movement"""
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("torch"):
		VIEW_MODE = SPECTRAL if VIEW_MODE == FLASHLIGHT else FLASHLIGHT
		cycle_views()

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if footsteps_timer.time_left <= 0 and is_on_floor():
			footsteps.play()
			footsteps_timer.start(0.4)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	velocity.x = velocity.x * delta
	velocity.z = velocity.z * delta

	# Ray casting to see what the player is looking at
	var looking_at = raycast3d.get_collider()

	if Input.is_action_just_pressed("open_backpack"):
		if backpack.opened:
			close_backpack()
		else:
			open_backpack()
	
	if Input.is_action_just_pressed("ui_cancel"):
		if backpack.opened:
			close_backpack()

	if focusing_node != null and looking_at != focusing_node:
		tooltipButton.hide()
		tooltipLabel.hide()
		if focusing_node.is_in_group("ITEM_3D"):
			focusing_node.unfocus()

	if looking_at != focusing_node:
		if looking_at != null and looking_at.is_in_group("ITEM_3D"):
			looking_at.focus()
			tooltipButton.show()
			tooltipLabel.show()
			tooltipLabel.text = "pickup"
		elif looking_at != null and looking_at.name == "door_collider":
			tooltipButton.show()
			tooltipLabel.show()
			tooltipLabel.text = "close" if looking_at.parent_door.open else "open"
		focusing_node = looking_at

	if Input.is_action_just_pressed("interact") and focusing_node != null:
		if focusing_node.is_in_group("ITEM_3D"):
			focusing_node.queue_free()
			open_backpack(focusing_node)
		elif focusing_node.name == "door_collider":
			focusing_node.parent_door.toggle_open()

	move_and_slide()

func cycle_views():
	sound_radar.stop()
	sound_radar_loop.stop()
	if VIEW_MODE == SPECTRAL:
		sound_flashlight.play()
	else:
		sound_radar_off.play()
		
	for element in flashlight_view_visible:
		if element == flashlightView:
			element.show()
		else:
			element.hide()
	for element in spectral_view_visible:
		element.hide()
		
	await get_tree().create_timer(0.4).timeout 
	
	if VIEW_MODE == FLASHLIGHT:
		sound_flashlight.play()
		
		for element in flashlight_view_visible:
			element.show()
		for element in spectral_view_visible:
			element.hide()
		UI.get_material().set_shader_parameter("ui_color",Color(1,0.7450980392156863,0.4980392156862745,1))
	elif VIEW_MODE == SPECTRAL:
		sound_radar.play()
		
		for element in flashlight_view_visible:
			element.hide()
		for element in spectral_view_visible:
			element.show()
		
		UI.get_material().set_shader_parameter("ui_color",Color(0.3333333333333333,1,1,1))
		
		await get_tree().create_timer(2.43).timeout 
		
		if VIEW_MODE == SPECTRAL:
			sound_radar_loop.play()

func _on_use_item(item_name: String):
	if item_name == "BATTERY":
		power.valueFloat = min(power.valueFloat + 50, 100)
	if item_name == "CHOCOLATE":
		power.freeze(5)
	if item_name == "COFFEE":
		current_speed = FAST_SPEED
		var timer = Timer.new()
		timer.set_wait_time(15)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		await timer.timeout
		current_speed = SPEED

func in_range(node:Node3D):
	if not node in available_interactions:
		available_interactions.append(node)

func out_range(node:Node3D):
	if node in available_interactions:
		available_interactions.erase(node)

func draw_item():
	"""Called when an interactable item is searched, adds an item to the player's inventory"""
	pass


func open_backpack(item = null):
	backpack.open(item)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false

func close_backpack():
	backpack.close()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true

func death():
	if is_game_over == true or not END_GAME_WHEN_OUT_OF_POWER:
		if power.power_is_zero.is_connected(death):
			power.power_is_zero.disconnect(death)
		return
	power.power_is_zero.disconnect(death)
	
	# enter the game over mode
	gos_viewport.visible = true
	game_timer.stop()
	gos.set_time(game_timer.get_time())
	gos.set_best_time(game_timer.get_best_time())
	is_game_over = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_captured = false
	
	# end sounds
	sound_radar.stop()
	sound_radar_loop.stop()
	
	if VIEW_MODE == SPECTRAL:
		gos.get_child(1).get_material().set_shader_parameter("ui_color",Color(0.3333333333333333,1,1,1))
