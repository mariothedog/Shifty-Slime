extends Node2D

export var level_width = 2678
export var level_ceiling = -578
export var level_floor = 1472

# Audio constants
const MUSIC_VOLUME = -15

func _ready():
	$Player/Camera2D.limit_right = level_width
	$Player/Camera2D.limit_top = level_ceiling
	$Player/Camera2D.limit_bottom = level_floor
	
	$Music.volume_db = MUSIC_VOLUME

func transition_to_next_level():
	if global.current_level != 4:
		$AnimationPlayer.play("Fade Out")
		
		yield($AnimationPlayer, "animation_finished")
	
	global.go_to_next_level()
