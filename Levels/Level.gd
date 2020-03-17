extends Node2D

export var level_size = 3574

func _ready():
	$Walls/Right.position.x = level_size
	$Player/Camera2D.limit_right = level_size
