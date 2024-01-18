extends Control


func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().change_scene_to_file("res://mainMenu.tscn")
