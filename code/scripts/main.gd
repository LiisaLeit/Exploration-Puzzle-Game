extends Node3D

signal close_main_door
signal close_restroom
signal close_library_living_room
signal close_kitchen_dining_room
signal close_bedroom

var porch_scene = preload("res://scenes/porch.tscn")
var yard_scene = preload("res://scenes/yard.tscn")
var hallway_scene = preload("res://scenes/hallway.tscn")
var restroom_scene = preload("res://scenes/restroom.tscn")
var living_room_scene = preload("res://scenes/living_room.tscn")
var library_scene = preload("res://scenes/library.tscn")
var kitchen_scene = preload("res://scenes/kitchen.tscn")
var dining_room_scene = preload("res://scenes/dining_room.tscn")
var bedroom_scene = preload("res://scenes/bedroom.tscn")

var player

var porch
var yard
var hallway
var restroom
var living_room
var library
var kitchen
var dining_room
var bedroom

var mirror_riddle_solved = false
var piano_riddle_solved = false
var safe_riddle_solved = false
var final_riddle_solved = false
var door_closed = false

var inside = false
var outside = true


func _ready():
	player = get_node("Player")
	
	yard = yard_scene.instantiate()
	add_child(yard)
	
	porch = porch_scene.instantiate()
	add_child(porch)
	
	hallway = hallway_scene.instantiate()
	add_child(hallway)
	
	restroom = restroom_scene.instantiate()
	add_child(restroom)


func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://mainMenu.tscn")
	if mirror_riddle_solved and player.position.x > 2.7:
		close_restroom.emit()
		restroom.queue_free()
		living_room = living_room_scene.instantiate()
		add_child(living_room)
		library = library_scene.instantiate()
		add_child(library)
		mirror_riddle_solved = false
	elif piano_riddle_solved and player.position.x < 5 and player.position.z > -4.5:
		close_library_living_room.emit()
		living_room.queue_free()
		library.queue_free()
		get_node("Piano").queue_free()
		kitchen = kitchen_scene.instantiate()
		add_child(kitchen)
		dining_room = dining_room_scene.instantiate()
		add_child(dining_room)
		piano_riddle_solved = false
	elif safe_riddle_solved and player.position.y > 2.3:
		close_kitchen_dining_room.emit()
		kitchen.queue_free()
		dining_room.queue_free()
		get_node("Safe").queue_free()
		bedroom = bedroom_scene.instantiate()
		add_child(bedroom)
		safe_riddle_solved = false
	elif final_riddle_solved and player.position.y < 2.3:
		close_bedroom.emit()
		bedroom.queue_free()
		yard = yard_scene.instantiate()
		add_child(yard)
		porch = porch_scene.instantiate()
		add_child(porch)
		final_riddle_solved = false
	elif !door_closed and (player.position.z < -5.5 or player.position.x < 3.0 and player.position.z < -3.0):
		close_main_door.emit()
		yard.queue_free()
		porch.queue_free()
		door_closed = true
	
	if player.position.z < 0 and !inside:
		inside = true
		outside = false
		get_node("Sounds/InsideWind").playing = true
		get_node("Sounds/OutsideWind").playing = false
	elif player.position.z > 0 and !outside:
		inside = false
		outside = true
		get_node("Sounds/InsideWind").playing = false
		get_node("Sounds/OutsideWind").playing = true


func _on_mirror_riddle_solved():
	mirror_riddle_solved = true

func _on_doors_kitchen_key_picked():
	piano_riddle_solved = true

func _on_doors_second_floor_key_picked():
	safe_riddle_solved = true
	
func _on_final_painting_riddle_solved():
	final_riddle_solved = true
