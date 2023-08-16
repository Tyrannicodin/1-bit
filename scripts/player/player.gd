extends CharacterBody3D

const SPEED = 3
const JUMP_VELOCITY = 4.5

@export var VIEW_MODE = "flashlight"

@onready var torch_power = $GameContainer/GameViewport/MainViewportContainer/MainViewport/Camera/Torch.light_energy
@onready var camera = $"cameraLoc"
@onready var ghostCamera = $"ghostCameraLoc"
@onready var ghostViewport = $GameContainer/GameViewport/GhostViewportContainer
@onready var spectralView = $GameContainer/GameViewport/MainViewportContainer/MainViewport/SpectralView
@onready var flashlightView = $GameContainer/GameViewport/MainViewportContainer/MainViewport/FlashlightView
@onready var spectralViewDither = $GameContainer/GameViewport/GhostViewportContainer/SpectralFilter
@onready var flashlight = $GameContainer/GameViewport/MainViewportContainer/MainViewport/Camera/Torch
@onready var radar = $GameContainer/GameViewport/MainViewportContainer/MainViewport/Camera/RadarLight
@onready var tooltipButton = $GameContainer/GameViewport/UIViewport/Tooltip/Button
@onready var tooltipLabel = $GameContainer/GameViewport/UIViewport/Tooltip/Label
@onready var flashlightSelected = $GameContainer/GameViewport/UIViewport/VBoxContainer/Mainhand/FlashlightBox/SelectedSlot
@onready var radarSelected = $GameContainer/GameViewport/UIViewport/VBoxContainer/Mainhand/RadarBox/SelectedSlot
@onready var UI = $UIRect
@onready var batteryBar = $"GameContainer/GameViewport/UIViewport/VBoxContainer/Power Bar/ProgressBar"
@onready var raycast3d = $cameraLoc/RayCast3D

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

var mouse_captured = false
var available_interactions = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# THe previous node that the player looked at.
var last_looked_at = null

func _ready():
	"""Setup for game"""
	mouse_captured = true # Capture the mouse and remember it for later
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	get_tree().call_group("interactable", "get_available", self)
	var minimum_distance = INF
	var minimum_node = null
	for node in available_interactions:
		if minimum_distance > global_position.distance_squared_to(node.global_position):
			minimum_distance = global_position.distance_squared_to(node.global_position)
			minimum_node = node
	if minimum_node:
		tooltipButton.show()
		tooltipLabel.show()
		tooltipButton.text = minimum_node.tooltip_button
		tooltipLabel.text = minimum_node.tooltip_text
	else:
		tooltipButton.hide()
		tooltipLabel.hide()

func _physics_process(delta):
	"""Handle the player's input and movement"""
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("torch"):
		VIEW_MODE = "spectral" if VIEW_MODE == "flashlight" else "flashlight"
		cycle_views()
	
	if Input.is_action_just_pressed("interact"):
		var minimum_distance = INF
		var minimum_node = null
		for node in get_tree().get_nodes_in_group("interactable"):
			if minimum_distance > global_position.distance_squared_to(node.global_position):
				minimum_distance = global_position.distance_squared_to(node.global_position)
				minimum_node = node
		if minimum_node:
			minimum_node.call("interact", self)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if mouse_captured:
			mouse_captured = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			mouse_captured = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if footsteps_timer.time_left <= 0 and is_on_floor():
			footsteps.play()
			footsteps_timer.start(0.4)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Ray casting to see what the player is looking at
	var looking_at = raycast3d.get_collider()

	if last_looked_at != null and looking_at != last_looked_at:
		if last_looked_at.is_in_group("ITEM_3D"):
			last_looked_at.unfocus()

	if looking_at != last_looked_at:
		if looking_at != null and looking_at.is_in_group("ITEM_3D"):
			looking_at.focus()

		last_looked_at = looking_at

	move_and_slide()

func cycle_views():
	sound_radar.stop()
	sound_radar_loop.stop()
	if VIEW_MODE == "spectral":
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
	
	if VIEW_MODE == "flashlight":
		sound_flashlight.play()
		
		for element in flashlight_view_visible:
			element.show()
		for element in spectral_view_visible:
			element.hide()
		UI.get_material().set_shader_parameter("ui_color",Color(1,0.7450980392156863,0.4980392156862745,1))
	elif VIEW_MODE == "spectral":
		sound_radar.play()
		
		for element in flashlight_view_visible:
			element.hide()
		for element in spectral_view_visible:
			element.show()
		
		UI.get_material().set_shader_parameter("ui_color",Color(0.3333333333333333,1,1,1))
		
		await get_tree().create_timer(2.43).timeout 
		
		if VIEW_MODE == "spectral":
			sound_radar_loop.play()

func in_range(node:Node3D):
	if not node in available_interactions:
		available_interactions.append(node)

func out_range(node:Node3D):
	if node in available_interactions:
		available_interactions.erase(node)

func draw_item():
	"""Called when an interactable item is searched, adds an item to the player's inventory"""
	pass
