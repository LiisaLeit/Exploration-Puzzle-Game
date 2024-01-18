extends Node3D


const RAY_LENGTH = 500.0

var camera
var player

var label
var image
var timer

var letter_two
var letter_three
var letter_five

var zoom = false

var letters = {
	"letterOne": null,
	"letterTwo": null,
	"letterThree": null,
	"letterFour": null,
	"letterFive": null,
}


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	
	label = get_node("/root/Main/Player/Pivot/Camera/Info")
	image = get_node("/root/Main/Player/Pivot/Camera/Image")
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 7.0
	timer.timeout.connect(_on_timer_timeout)
	
	letter_two = get_node("LetterPageTwo")
	letter_two.hide()
	
	letter_three = get_node("LetterPageThree")
	letter_three.hide()
	
	letter_five = get_node("LetterPageFive")
	letter_five.hide()
	
	letters["letterOne"] = get_node("/root/Main/Player/Pivot/Camera/LetterOne")
	letters["letterTwo"] = get_node("/root/Main/Player/Pivot/Camera/LetterTwo")
	letters["letterThree"] = get_node("/root/Main/Player/Pivot/Camera/LetterThree")
	letters["letterFour"] = get_node("/root/Main/Player/Pivot/Camera/LetterFour")
	letters["letterFive"] = get_node("/root/Main/Player/Pivot/Camera/LetterFive")


func _input(event):
	if event.is_action_pressed("interact"):
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mousepos)
		var to = from + camera.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [player]
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result and result.collider.is_in_group("letters"):
			var collider_name = result.collider.to_string().split(":")[0]
			zoom = !zoom
			set_image(collider_name)
		else:
			image.show()
			for key in letters:
				letters[key].hide()


func set_image(image_name):
	if zoom:
		get_node("PaperTaken").play()
		image.hide()
		letters[image_name].show()
		if image_name == "letterFive":
			timer.start()
	else:
		image.show()
		letters[image_name].hide()


func _on_timer_timeout():
	label.text = "It's time to go"


func _on_mirror_riddle_solved():
	get_node("LetterTwoSound").play()
	letter_two.show()

func _on_piano_riddle_solved():
	get_node("LetterThreeSound").play()
	letter_three.show()

func _on_safe_riddle_solved():
	get_node("LetterFourSound").play()

func _on_final_painting_riddle_solved():
	get_node("PaintingComplete").play()
	letter_five.show()
