extends Area2D

func _on_Slime_body_entered(_body):
	get_parent().transition_to_next_level()
