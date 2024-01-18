extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://controls.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
