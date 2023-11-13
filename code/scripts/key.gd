extends Node3D

signal picked
var interacting = false # shows whether the player is near the key


func _ready():
	pass

func _process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("interact") && interacting:
		for body in $Area3D.get_overlapping_bodies():
			if body.is_in_group("player"):
				picked.emit()
				queue_free()


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		interacting = true
