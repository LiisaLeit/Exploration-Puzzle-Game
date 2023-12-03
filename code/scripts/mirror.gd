extends Node3D

const RAY_LENGTH = 1000.0

var letter_j
var letter_e
var rings
var camera
var player

var j_picked = false
var e_picked = false
var rings_picked = false

var j_put = false
var e_put = false
var rings_put = false

var signal_emitted = false
signal riddle_solved


func _ready():
	letter_j = get_node("J")
	letter_e = get_node("E")
	rings = get_node("Rings")
	camera = get_viewport().get_camera_3d()
	player = get_node('/root/Main/Player')


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
		if result and result.collider.is_in_group("first_riddle"):
			if "LetterJArea" in result.collider.to_string():
				j_picked = true
				remove_child(letter_j)
			elif "LetterEArea" in result.collider.to_string():
				e_picked = true
				remove_child(letter_e)
			elif "RingsArea" in result.collider.to_string():
				rings_picked = true
				remove_child(rings)
			elif "MirrorArea" in result.collider.to_string():
				put_letters()


func put_letters():
	if j_picked and j_put == false:
		add_child(letter_j)
		letter_j.position = Vector3(-22.85, 22.401, 19.079)
		letter_j.rotation.z = deg_to_rad(0)
		j_put = true
		letter_j.remove_from_group("first_riddle")
	elif e_picked and e_put == false:
		add_child(letter_e)
		letter_e.position = Vector3(-26.27, 22.772, 19.079)
		letter_e.rotation.y = deg_to_rad(90)
		letter_e.rotation.z = deg_to_rad(0)
		e_put = true
		letter_e.remove_from_group("first_riddle")
	elif rings_picked and rings_put == false:
		add_child(rings)
		rings.position = Vector3(-24.74, 22.59, 19.065)
		rings.rotation.x = deg_to_rad(0)
		rings.rotation.y = deg_to_rad(90)
		rings.rotation.z = deg_to_rad(0)
		rings_put = true
		rings.remove_from_group("first_riddle")
	if j_put && e_put && rings_put:
		riddle_solved.emit()
		signal_emitted = true
