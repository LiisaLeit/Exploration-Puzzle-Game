extends Node3D


var sounds = [
	"CreepyVocal", 
	"GhostSound", 
	"CreakingKnocking", 
	"CreakingKnocking2", 
	"CreakingKnocking3", 
	"CreakingKnocking4",
	"CreakingKnocking5", 
	"CreakingKnocking6", 
	"CreakingKnocking7", 
	"WoodenChairMove", 
	"WoodenChairMove2"
]

var sounds_played = []

var timer = 0.0
var timer_limit


func _ready():
	timer_limit = randi() % 11 + 10


func _process(delta):
	timer += delta
	if timer > timer_limit:
		timer = 0.0
		timer_limit = randi() % 11 + 10
		play_sound()


func play_sound():
	if sounds.is_empty():
		sounds = sounds_played
		sounds_played = []
	var sound = sounds.pick_random()
	sounds_played.append(sound)
	sounds.erase(sound)
	get_node(sound).play()
	

func _on_mirror_riddle_solved():
	timer_limit += 16.0

func _on_piano_riddle_solved():
	timer_limit += 5.0

func _on_safe_riddle_solved():
	timer_limit += 8.0

func _on_final_painting_riddle_solved():
	timer_limit += 6.0
