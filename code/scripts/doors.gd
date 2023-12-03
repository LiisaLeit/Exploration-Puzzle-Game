extends Node3D

const RAY_LENGTH = 1000.0

var camera
var player

var library_key

var door_closed = {
	"BigDoor": true,
	"RestroomDoor": true,
	"KitchenDoor": true,
	"LivingRoomDoor": true,
	"LibraryDoor": true
}

var door_key_picked = {
	"BigDoor": true,
	"RestroomDoor": true,
	"KitchenDoor": true,
	"LivingRoomDoor": true,
	"LibraryDoor": false
}

var door_rotation = {
	"BigDoor": [0, -90],
	"RestroomDoor": [0, 90],
	"KitchenDoor": [-180, -90],
	"LivingRoomDoor": [90, 180],
	"LibraryDoor": [90, 180]
}


func _ready():
	library_key = get_node("LibraryRoomKey")
	library_key.hide()
	
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
		if result and result.collider.is_in_group("doors"):
			var door = result.collider.to_string().split(":")[0]
			open_door(door, door_closed[door], door_key_picked[door])
		elif result and "LibraryRoomKey" in result.collider.to_string():
			door_key_picked["LibraryDoor"] = true
			library_key.queue_free()
			

func open_door(door, closed, key_picked):
	var node = get_node(door)
	if closed and key_picked:
		var tween = get_tree().create_tween()
		tween.tween_property(node, "rotation_degrees", Vector3(0, door_rotation[door][1], 0), 1.0)
		door_closed[door] = false
	elif !closed:
		var tween = get_tree().create_tween()
		tween.tween_property(node, "rotation_degrees", Vector3(0, door_rotation[door][0], 0), 1.0)
		door_closed[door] = true


func _on_mirror_riddle_solved():
	library_key.show()
