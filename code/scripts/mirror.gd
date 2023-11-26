extends Node3D

var letter_j
var letter_e
var rings

var in_j_area = false
var in_e_area = false
var in_rings_area = false

var j_picked = false
var e_picked = false
var rings_picked = false

var j_put = false
var e_put = false
var rings_put = false

var interacting = false

signal riddle_solved


func _ready():
	letter_j = get_node("J")
	letter_e = get_node("E")
	rings = get_node("Rings")


func _unhandled_input(event):
	if event.is_action_pressed("interact") && interacting:
		if j_picked:
			add_child(letter_j)
			letter_j.position = Vector3(-22.85, 22.401, 19.079)
			letter_j.rotation.z = deg_to_rad(0)
			j_put = true
			j_picked = false
		elif e_picked:
			add_child(letter_e)
			letter_e.position = Vector3(-26.27, 22.772, 19.079)
			letter_e.rotation.y = deg_to_rad(90)
			letter_e.rotation.z = deg_to_rad(0)
			e_put = true
			e_picked = false
		elif rings_picked:
			add_child(rings)
			rings.position = Vector3(-24.74, 22.59, 19.065)
			rings.rotation.x = deg_to_rad(0)
			rings.rotation.y = deg_to_rad(90)
			rings.rotation.z = deg_to_rad(0)
			rings_put = true
			rings_picked = false
	if event.is_action_pressed("interact"):
		if in_j_area:
			j_picked = true
			remove_child(letter_j)
			in_j_area = false
		elif in_e_area:
			e_picked = true
			remove_child(letter_e)
			in_e_area = false
		elif in_rings_area:
			rings_picked = true
			remove_child(rings)
			in_rings_area = false
	if j_put && e_put && rings_put:
		riddle_solved.emit()
		j_put = false
		e_put = false
		rings_put = false


func _on_letter_j_area_body_entered(body):
	if body.is_in_group("player"):
		in_j_area = true

func _on_letter_j_area_body_exited(body):
	if body.is_in_group("player"):
		in_j_area = false

func _on_letter_e_area_body_entered(body):
	if body.is_in_group("player"):
		in_e_area = true

func _on_letter_e_area_body_exited(body):
	if body.is_in_group("player"):
		in_e_area = false

func _on_rings_area_body_entered(body):
	if body.is_in_group("player"):
		in_rings_area = true

func _on_rings_area_body_exited(body):
	if body.is_in_group("player"):
		in_rings_area = false

func _on_mirror_area_body_entered(body):
	if body.is_in_group("player"):
		interacting = true

func _on_mirror_area_body_exited(body):
	if body.is_in_group("player"):
		interacting = false
