extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var torch_power = $MainViewportContainer/MainViewport/Camera/Torch.light_energy
@onready var camera = $"cameraLoc"
@onready var ghostCamera = $"ghostCameraLoc"
@onready var ghostViewport = $GhostViewportContainer
@onready var spectralView = $MainViewportContainer/MainViewport/SpectralView
@onready var flashlightView = $MainViewportContainer/MainViewport/FlashlightView
@onready var spectralViewDither = $GhostViewportContainer/SpectralFilter
@onready var flashlight = $MainViewportContainer/MainViewport/Camera/Torch
@onready var radar = $MainViewportContainer/MainViewport/Camera/RadarLight
#@onready var tooltipButton = $MainViewportContainer/MainViewport/FlashlightView/Tooltip/Button
#@onready var tooltipLabel = $MainViewportContainer/MainViewport/FlashlightView/Tooltip/Label
@onready var tooltipButton = $MainViewportContainer/MainViewport/Tooltip/Button
@onready var tooltipLabel = $MainViewportContainer/MainViewport/Tooltip/Label

var mouse_captured = false
var available_interactions = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func cycle_views():
	spectralView.visible = not spectralView.visible
	spectralViewDither.visible = not spectralViewDither.visible
	flashlightView.visible = not flashlightView.visible
	flashlight.light_energy = 0 if flashlight.light_energy == torch_power else torch_power
	radar.visible = not radar.visible
	ghostViewport.visible = not ghostViewport.visible

func in_range(node:Node3D):
	if not node in available_interactions:
		available_interactions.append(node)

func out_range(node:Node3D):
	if node in available_interactions:
		available_interactions.erase(node)
