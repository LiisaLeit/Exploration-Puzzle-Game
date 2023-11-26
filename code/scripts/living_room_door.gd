extends Node3D


var closed = true
var interacting = false

var key
var in_key_area = false
var key_picked = false


func _ready():
	key = get_node("LivingRoomKey")
	key.hide()


func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if interacting:
			interact()
		elif in_key_area && key.is_visible():
			key_picked = true
			key.queue_free()


func interact():
	if closed && key_picked:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, 180, 0), 1.0)
		closed = false
	elif !closed:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, 90, 0), 1.0)
		closed = true


func _on_living_room_door_area_body_entered(body):
	if body.is_in_group("player"):
		interacting = true

func _on_living_room_door_area_body_exited(body):
	if body.is_in_group("player"):
		interacting = false

func _on_mirror_riddle_solved():
	key.show()

func _on_living_room_key_area_body_entered(body):
	if body.is_in_group("player"):
		in_key_area = true

func _on_living_room_key_area_body_exited(body):
	if body.is_in_group("player"):
		in_key_area = false
