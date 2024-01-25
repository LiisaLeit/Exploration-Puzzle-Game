extends CharacterBody3D


const SPEED = 4.0

@onready var pivot := $Pivot
@onready var camera := $Pivot/Camera

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var inside = false
var outside = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if position.z < 0 and !inside:
			inside = true
			outside = false
			get_node("Sounds/MovingInside").playing = true
			get_node("Sounds/MovingOutside").playing = false
		elif position.z > 0 and !outside:
			inside = false
			outside = true
			get_node("Sounds/MovingInside").playing = false
			get_node("Sounds/MovingOutside").playing = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if position.z < 0:
			inside = false
			get_node("Sounds/MovingInside").playing = false
		else:
			outside = false
			get_node("Sounds/MovingOutside").playing = false

	move_and_slide()


func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * 0.003)
			camera.rotate_x(-event.relative.y * 0.003)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))
