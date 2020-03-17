extends Node2D

export var level_width = 2678
export var level_ceiling = -578

func _ready():
	$Player/Camera2D.limit_right = level_width
	$Player/Camera2D.limit_top = level_ceiling
