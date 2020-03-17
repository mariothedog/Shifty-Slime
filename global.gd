extends Node

var current_level = 0

func go_to_next_level():
	current_level += 1
	if get_tree().change_scene("res://Levels/Level%s.tscn" % current_level) != OK:
		print_debug("An error occured while changing level.")
