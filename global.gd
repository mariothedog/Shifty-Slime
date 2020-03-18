extends Node

var current_level = 0

func _go_to_next_level():
	current_level += 1
	_restart_level()

func _restart_level():
	if get_tree().change_scene("res://Levels/Level%s.tscn" % current_level) != OK:
		print_debug("An error occured while restarting the level.")
