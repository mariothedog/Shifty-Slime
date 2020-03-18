extends Node

var current_level = 3

func go_to_next_level():
	current_level += 1
	restart_level()

func restart_level():
	if get_tree().change_scene("res://Levels/Level%s.tscn" % current_level) != OK:
		print_debug("An error occured while restarting the level.")
