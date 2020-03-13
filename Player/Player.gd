extends KinematicBody2D

export var speed = 300

const GRAVITY = 400

var velocity = Vector2()

func _physics_process(delta):
	input()
	movement(delta)
	animate()

func input():
	# Growing
	var scale_dir = Vector2(1, 1)
	
	if Input.is_action_pressed("expand_up"):
		scale_dir += Vector2(-0.3, 0.5)
	
	if Input.is_action_pressed("shrink"):
		scale_dir += Vector2(0.3, -0.5)
	
	$Sprite.scale = lerp($Sprite.scale, scale_dir, 0.15)
	
	# Moving
	var input_vel_x = 0
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
	
	velocity.x = input_vel_x * speed

func movement(delta):
	#velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity)

func animate():
	pass
