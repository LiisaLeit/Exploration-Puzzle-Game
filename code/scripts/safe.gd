extends Node3D


signal riddle_solved

const RAY_LENGTH = 500.0
const ROLL_ROTATION = [Vector3(0, 0, 0), Vector3(90, 0, 0), Vector3(180, 0, 0), Vector3(270, 0, 0)]
const SEQUENCE = [3, 4, 2]

var camera
var player

var label
var image
var timer

var roll1
var roll2
var roll3

var code = [1, 1, 1]

var roll_one_rotation = 0
var roll_two_rotation = 0
var roll_three_rotation = 0

var numbers = {
	"numberOne": null,
	"numberTwo": null,
	"numberThree": null,
}

var zoom = false

var signal_emitted = false


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	roll1 = get_node("SafeDoor/Roll1")
	roll2 = get_node("SafeDoor/Roll2")
	roll3 = get_node("SafeDoor/Roll3")
	image = get_node("/root/Main/Player/Pivot/Camera/Image")
	
	numbers["numberOne"] = get_node("/root/Main/Player/Pivot/Camera/NumberOne")
	numbers["numberTwo"] = get_node("/root/Main/Player/Pivot/Camera/NumberTwo")
	numbers["numberThree"] = get_node("/root/Main/Player/Pivot/Camera/NumberThree")
	
	label = get_node("/root/Main/Player/Pivot/Camera/Info")
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0
	timer.timeout.connect(_on_timer_timeout)


func _input(event):
	if event.is_action_pressed("interact"):
		if signal_emitted:
			return
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mousepos)
		var to = from + camera.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [player]
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result and "Roll" in result.collider.to_string():
			var collider_name = result.collider.to_string().split(":")[0]
			rotate_roll(collider_name)
			check_numbers()
		elif result and "SafeDoor" in result.collider.to_string():
			timer.start()
			label.text = "I think I saw some numbers around."
		elif result and result.collider.is_in_group("numbers"):
			var collider_name = result.collider.to_string().split(":")[0]
			zoom = !zoom
			set_image(collider_name)
		else:
			image.show()
			for key in numbers:
				numbers[key].hide()


func rotate_roll(roll):
	var angle
	var tween = get_tree().create_tween()
	if roll == "Roll1":
		roll_one_rotation += 1
		angle = roll_one_rotation % 4
		code[0] = angle + 1
		tween.tween_property(roll1, "rotation_degrees", ROLL_ROTATION[angle], 0.5)
	elif roll == "Roll2":
		roll_two_rotation += 1
		angle = roll_two_rotation % 4
		code[1] = angle + 1
		tween.tween_property(roll2, "rotation_degrees", ROLL_ROTATION[angle], 0.5)
	else:
		roll_three_rotation += 1
		angle = roll_three_rotation % 4
		code[2] = angle + 1
		tween.tween_property(roll3, "rotation_degrees", ROLL_ROTATION[angle], 0.5)
	get_node("RollScrolling").play()

func check_numbers():
	if code.hash() == SEQUENCE.hash():
		get_node("SafeDoorOpen").play()
		riddle_solved.emit()
		signal_emitted = true

func set_image(image_name):
	if zoom:
		get_node("PaperTaken").play()
		timer.start()
		label.text = "Hmm... At first glance it's just a number, but there's more to it. Some kind of code, maybe?"
		image.hide()
		numbers[image_name].show()
	else:
		image.show()
		numbers[image_name].hide()


func _on_timer_timeout():
	timer.stop()
	label.text = ""


func _on_riddle_solved():
	var tween = get_tree().create_tween()
	var node = get_node("SafeDoor")
	tween.tween_property(node, "rotation_degrees", Vector3(0, 60, 0), 0.5)
