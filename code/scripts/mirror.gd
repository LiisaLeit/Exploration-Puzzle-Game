extends Node3D


signal riddle_solved

const RAY_LENGTH = 500.0

var camera
var player

var label
var timer

var letter_j
var letter_e
var rings

var j_picked = false
var e_picked = false
var rings_picked = false

var j_put = false
var e_put = false
var rings_put = false

var signal_emitted = false


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	
	label = get_node("/root/Main/Player/Pivot/Camera/Info")
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.timeout.connect(_on_timer_timeout)
	
	letter_j = get_node("James")
	letter_e = get_node("Evelyn")
	rings = get_node("Rings")


func _input(event):
	if signal_emitted:
		return
	if event.is_action_pressed("interact"):
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mousepos)
		var to = from + camera.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [player]
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result and "LetterJArea" in result.collider.to_string() and not j_picked:
			get_node("JPickUp").play()
			j_picked = true
			remove_child(letter_j)
		elif result and "LetterEArea" in result.collider.to_string() and not e_picked:
			get_node("EPickUp").play()
			e_picked = true
			remove_child(letter_e)
		elif result and "RingsArea" in result.collider.to_string() and not rings_picked:
			get_node("RPickUp").play()
			rings_picked = true
			remove_child(rings)
		elif result and "MirrorArea" in result.collider.to_string():
			put_letters()


func put_letters():
	var sound = get_node("LetterPut")
	if j_picked and j_put == false:
		sound.play()
		add_child(letter_j)
		letter_j.position = Vector3(0.059, 1.018, 0.265)
		letter_j.rotation.y = deg_to_rad(0)
		letter_j.rotation.z = deg_to_rad(0)
		j_put = true
	elif e_picked and e_put == false:
		sound.play()
		add_child(letter_e)
		letter_e.position = Vector3(0.059, 1.070, -0.227)
		letter_e.rotation.x = deg_to_rad(0)
		letter_e.rotation.y = deg_to_rad(0)
		letter_e.rotation.z = deg_to_rad(0)
		e_put = true
	elif rings_picked and rings_put == false:
		sound.play()
		add_child(rings)
		rings.position = Vector3(0.061, 1.045, 0.005)
		rings.rotation.x = deg_to_rad(0)
		rings.rotation.y = deg_to_rad(0)
		rings.rotation.z = deg_to_rad(-90)
		rings_put = true
	else:
		timer.start()
		label.text = "Looks like some pieces are missing."
	if j_put && e_put && rings_put:
		timer.start()
		label.text = "All the pieces are in place now."
		riddle_solved.emit()
		signal_emitted = true


func _on_timer_timeout():
	timer.stop()
	label.text = ""
