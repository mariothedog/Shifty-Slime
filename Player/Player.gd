extends KinematicBody2D

export var speed = 300

const GRAVITY = 400

var velocity = Vector2()

var scale_dir = Vector2(1, 1)

onready var original_polygon = $CollisionPolygon2D.polygon

func _physics_process(delta):
	scale_dir = Vector2(1, 1)
	input()
	update_collision_shapes()
	movement(delta)
	animate()

func input():
	# Growing
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

func update_collision_shapes():
	if Vector2(stepify($Sprite.scale.x, 0.01), stepify($Sprite.scale.y, 0.01)) != scale_dir:
		for i in range(len($CollisionPolygon2D.polygon)):
			$CollisionPolygon2D.polygon[i].x = original_polygon[i].x * $Sprite.scale.x
			$CollisionPolygon2D.polygon[i].y = original_polygon[i].y * $Sprite.scale.y
		
		$CollisionPolygon2D.position = Vector2(0, -156) * $Sprite.scale # So the centre of enlargement is at the bottom of the middle of the sprite.

func movement(delta):
	#velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity)

func animate():
	pass
