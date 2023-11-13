extends Node3D

var closed = true 
var interacting = false # shows whether the player is near the door
var key_picked = false


func _ready():
	pass

func _process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("interact") && interacting:
		interact()
		interacting = false

func interact():
	if closed && key_picked:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, 90, 0), 1.0)
		closed = false
	elif !closed:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 1.0)
		closed = true

func _on_key_picked():
	key_picked = true

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		interacting = true
