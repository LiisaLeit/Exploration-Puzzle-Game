extends Node3D


signal kitchen_key_picked
signal second_floor_key_picked

const RAY_LENGTH = 500.0

var camera
var player

var timer

var library_key
var living_room_key
var kitchen_key
var second_floor_key

var game_end = false

var door_closed = {
	"BigDoor": true,
	"RestroomDoor": true,
	"KitchenDoor": true,
	"LivingRoomDoor": true,
	"LibraryDoor": true,
	"TrapDoor": true
}

var door_key_picked = {
	"BigDoor": true,
	"RestroomDoor": true,
	"KitchenDoor": false,
	"LivingRoomDoor": false,
	"LibraryDoor": false,
	"TrapDoor": false
}

const door_rotation = {
	"BigDoor": [0, -90],
	"RestroomDoor": [0, 90],
	"KitchenDoor": [-180, -90],
	"LivingRoomDoor": [90, 180],
	"LibraryDoor": [90, 180],
	"TrapDoor": [0, 90]
}


func _ready():
	camera = get_viewport().get_camera_3d()
	player = get_node("/root/Main/Player")
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	
	library_key = get_node("LibraryKey")
	library_key.hide()
	
	living_room_key = get_node("LivingRoomKey")
	living_room_key.hide()
	
	kitchen_key = get_node("KitchenKey")
	kitchen_key.hide()
	
	second_floor_key = get_node("SecondFloorKey")
	second_floor_key.hide()


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
		elif result and "LibraryKey" in result.collider.to_string():
			var sound = get_node("LibraryKeyPicked")
			sound.play()
			door_key_picked["LibraryDoor"] = true
			library_key.queue_free()
		elif result and "LivingRoomKey" in result.collider.to_string():
			var sound = get_node("LivingRoomKeyPicked")
			sound.play()
			door_key_picked["LivingRoomDoor"] = true
			living_room_key.queue_free()
		elif result and "KitchenKey" in result.collider.to_string():
			var sound = get_node("KitchenKeyPicked")
			sound.play()
			door_key_picked["KitchenDoor"] = true
			kitchen_key.queue_free()
			kitchen_key_picked.emit()
		elif result and "SecondFloorKey" in result.collider.to_string():
			var sound = get_node("SecondFloorKeyPicked")
			sound.play()
			door_key_picked["TrapDoor"] = true
			second_floor_key.queue_free()
			second_floor_key_picked.emit()
		elif result and "Gate" in result.collider.to_string() and game_end:
			timer.start()
			get_node("LetterFiveSound").play()


func open_door(door, closed, key_picked):
	var node = get_node(door)
	if closed and key_picked:
		var sound = get_node(door + "/DoorOpen")
		sound.play()
		var tween = get_tree().create_tween()
		if door == "TrapDoor":
			tween.tween_property(node, "rotation_degrees", Vector3(door_rotation[door][1], 0, -90), 1.0)
		else:
			tween.tween_property(node, "rotation_degrees", Vector3(0, door_rotation[door][1], 0), 1.0)
		door_closed[door] = false
	elif !closed:
		var sound = get_node(door + "/DoorClose")
		sound.play()
		var tween = get_tree().create_tween()
		if door == "TrapDoor":
			tween.tween_property(node, "rotation_degrees", Vector3(door_rotation[door][0], 0, -90), 1.0)
		else:
			tween.tween_property(node, "rotation_degrees", Vector3(0, door_rotation[door][0], 0), 1.0)
		door_closed[door] = true
	else:
		var sound = get_node(door + "/DoorOpenNoKey")
		sound.play()


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://final.tscn")


func _on_mirror_riddle_solved():
	var sound = get_node("FirstDoorsOpen")
	sound.play()
	library_key.show()
	living_room_key.show()

func _on_piano_riddle_solved():
	var sound = get_node("SecondDoorOpen")
	sound.play()
	kitchen_key.show()

func _on_safe_riddle_solved():
	var sound = get_node("ThirdDoorOpen")
	sound.play()
	second_floor_key.show()

func _on_main_close_main_door():
	if not door_closed["BigDoor"]:
		open_door("BigDoor", false, true)
	door_key_picked["BigDoor"] = false

func _on_main_close_restroom():
	if not door_closed["RestroomDoor"]:
		open_door("RestroomDoor", false, true)
	door_key_picked["RestroomDoor"] = false

func _on_main_close_library_living_room():
	if not door_closed["LivingRoomDoor"]:
		open_door("LivingRoomDoor", false, true)
	if not door_closed["LibraryDoor"]:
		open_door("LibraryDoor", false, true)
	door_key_picked["LivingRoomDoor"] = false
	door_key_picked["LibraryDoor"] = false

func _on_main_close_kitchen_dining_room():
	if not door_closed["KitchenDoor"]:
		open_door("KitchenDoor", false, true)
	door_key_picked["KitchenDoor"] = false

func _on_main_close_bedroom():
	if not door_closed["TrapDoor"]:
		open_door("TrapDoor", false, true)
	door_key_picked["TrapDoor"] = false
	door_key_picked["BigDoor"] = true
	game_end = true
