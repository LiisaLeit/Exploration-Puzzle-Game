extends Node3D


signal riddle_solved

const RAY_LENGTH = 500.0
const SEQUENCE = ["5-fs", "5-c", "4-ds", "4-f", "5-e", "5-as", "4-gs"]

var camera
var player

var image
var timer
var book

var pressed_keys = []

var zoom = false
var signal_emitted = false


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	
	image = get_node("/root/Main/Player/Pivot/Camera/Image")
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.timeout.connect(_on_timer_timeout)
	

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
		if result and result.collider.is_in_group("piano_keys"):
			var collider_name = result.collider.to_string().split(":")[0]
			pressed_keys.append(collider_name)
			var tween = get_tree().create_tween()
			var node = get_node(collider_name)
			tween.tween_property(node, "rotation_degrees", Vector3(4, node.rotation_degrees.y, 0), 0.3)
			tween.tween_property(node, "rotation_degrees", Vector3(0, node.rotation_degrees.y, 0), 0.3)
			get_node(collider_name+"/AudioStreamPlayer3D").play()
			check_pressed_keys()
		elif result and result.collider.is_in_group("books"):
			book = result.collider.to_string().split(":")[0]
			image.hide()
			get_node("/root/Main/Player/Pivot/Camera/" + book).show()
			get_node(book).play()
			timer.start()


func check_pressed_keys():
	if signal_emitted:
		return
	for i in range(len(pressed_keys)):
		if pressed_keys[i] != SEQUENCE[i]:
			pressed_keys = []
	if pressed_keys.hash() == SEQUENCE.hash():
		get_node("KeyplaceOpen").play()
		riddle_solved.emit()
		signal_emitted = true


func _on_timer_timeout():
	timer.stop()
	get_node("/root/Main/Player/Pivot/Camera/" + book).hide()
	image.show()


func _on_riddle_solved():
	var tween = get_tree().create_tween()
	var node = get_node("KeyPlace")
	tween.tween_property(node, "rotation_degrees", Vector3(0, 70, 0), 0.5)
