extends CharacterBody3D

const SPEED = 5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera

func _unhandled_input(event):
	# listening to the mouse input
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# subtract how far moved to the left
			pivot.rotate_y(-event.relative.x * 0.003) # multiply by small value as rotatiom is in radians
			camera.rotate_x(-event.relative.y * 0.003)
			# limim up and down rotation
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	# move in the direction where the camera os looking
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
