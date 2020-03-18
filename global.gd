extends Node

var current_level = 4

func go_to_next_level():
	current_level += 1
	if current_level == 5:
		go_to_main_menu()
	else:
		restart_level()

func restart_level():
	if get_tree().change_scene("res://Levels/Level%s.tscn" % current_level) != OK:
		print_debug("An error occured while restarting the level.")

func go_to_main_menu():
	if get_tree().change_scene("res://UI/Main Menu.tscn") != OK:
		print_debug("An error occured while going to the main menu scene.")
