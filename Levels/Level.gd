extends Node2D

export var level_width = 2678
export var level_ceiling = -578
export var level_floor = 1472

func _ready():
	$Player/Camera2D.limit_right = level_width
	$Player/Camera2D.limit_top = level_ceiling
	$Player/Camera2D.limit_bottom = level_floor

func _on_Slime_body_entered(_body):
	global._go_to_next_level()
