extends Control

# Audio constants
const MUSIC_VOLUME = -15

func _ready():
	global.current_level = 0
	
	$Music.volume_db = MUSIC_VOLUME

func _on_Play_pressed():
	$AnimationPlayer.play("Fade Out")
	
	yield($AnimationPlayer, "animation_finished")
	
	global.restart_level()
