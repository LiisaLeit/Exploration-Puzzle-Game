extends Node3D

var closed = true
var interacting = false


func _unhandled_input(event):
	if event.is_action_pressed("interact") && interacting:
		interact()


func interact():
	if closed:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, -90, 0), 1.0)
		closed = false
	elif !closed:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, -180, 0), 1.0)
		closed = true


func _on_kitchen_door_area_body_entered(body):
	if body.is_in_group("player"):
		interacting = true

func _on_kitchen_door_area_body_exited(body):
	if body.is_in_group("player"):
		interacting = false
