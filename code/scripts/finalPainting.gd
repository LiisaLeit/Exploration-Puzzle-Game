extends Node3D


signal riddle_solved

const RAY_LENGTH = 500.0
const POSITION = Vector3(-25.842, 42.595, -13.289)
const ROTATION = Vector3(deg_to_rad(90), 0, 0)
const SCALE = Vector3(4.635, 1, 6.871)

var camera
var player

var label
var timer

var pieces = 0

var signal_emitted = false


var pieces_picked = {
	"Part1": false,
	"Part2": false,
	"Part3": false,
	"Part4": false,
	"Part5": false,
	"Part6": false,
}

var pieces_put = {
	"Part1": false,
	"Part2": false,
	"Part3": false,
	"Part4": false,
	"Part5": false,
	"Part6": false
}


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	
	label = get_node("/root/Main/Player/Pivot/Camera/Info")
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.timeout.connect(_on_timer_timeout)


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
		if result and "FinalPainting" in result.collider.to_string():
			put_pieces()
		elif result and result.collider.is_in_group("painting"):
			var collider_name = result.collider.to_string().split(":")[0]
			if pieces_put[collider_name]:
				return
			timer.start()
			label.text = "I found a piece of a photo"
			get_node("PhotoPicked").play()
			get_node(collider_name).hide()
			pieces_picked[collider_name] = true


func put_pieces():
	for key in pieces_picked:
		if pieces_picked[key] and not pieces_put[key]:
			pieces += 1
			var node = get_node(key)
			node.set_position(POSITION)
			node.set_rotation(ROTATION)
			node.scale = SCALE
			node.show()
			pieces_put[key] = true
			get_node("PhotoPicked").play()
			if pieces == 6:
				break
			return
	if pieces != 6:
		return
	timer.start()
	label.text = "James and Evelyn"
	riddle_solved.emit()
	signal_emitted = true


func _on_timer_timeout():
	timer.stop()
	label.text = ""
