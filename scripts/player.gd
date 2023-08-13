extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var torch_power = $Camera/Torch.light_energy
@onready var camera = $Camera
var mouse_captured = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	mouse_captured = true # Capture the mouse and remember it for later
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		if mouse_captured: # If the mouse is captured and gets moved, rotate the camera
			rotate(Vector3(0, 1, 0), -event.relative.x * 0.001)
			camera.rotate(Vector3(1, 0, 0), -event.relative.y * 0.001)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 60)
			
func cycle_views():
	$SpectralView.visible = not $SpectralView.visible
	$SpectralViewDither.visible = not $SpectralViewDither.visible
	$FlashlightView.visible = not $FlashlightView.visible
	$Camera/Torch.light_energy = 0 if $Camera/Torch.light_energy == torch_power else torch_power
	$Camera/RadarLight.visible = not $Camera/RadarLight.visible

func _physics_process(delta):
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
		if not minimum_node:
			return
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
