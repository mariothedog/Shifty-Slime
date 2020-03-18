extends Node

var current_level = 0

var player

func go_to_next_level():
	if current_level == 4:
		player.thanks_for_playing_fade()
		
		yield(player.get_node("Tween"), "tween_all_completed")
		
		go_to_main_menu()
	else:
		current_level += 1
		restart_level()

func restart_level():
	if get_tree().change_scene("res://Levels/Level%s.tscn" % current_level) != OK:
		print_debug("An error occured while restarting the level.")

func go_to_main_menu():
	if get_tree().change_scene("res://UI/Main Menu.tscn") != OK:
		print_debug("An error occured while going to the main menu scene.")
