extends Node3D

const RAY_LENGTH = 1000.0

var camera
var player


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node('/root/Main/Player')


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
			var name = result.collider.to_string().split(":")[0]
			var tween = get_tree().create_tween()
			var node = get_node(name)
			print(name + " " + str(node.rotation_degrees.x))
			tween.tween_property(get_node(name), "rotation_degrees", Vector3(4, node.rotation_degrees.y, 0), 0.5)
			tween.tween_property(get_node(name), "rotation_degrees", Vector3(0, node.rotation_degrees.y, 0), 0.5)
