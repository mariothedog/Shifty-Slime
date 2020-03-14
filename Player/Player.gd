extends KinematicBody2D

export var speed = 300
export var jump_speed = 400

const GRAVITY = 400

var velocity = Vector2()

var scale_dir = Vector2(1, 1)

var jump = false

onready var original_polygon = $CollisionPolygon2D.polygon
onready var original_polygon_top = $"Top Area2D/CollisionPolygon2D".polygon

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
	
	var colliding_with_object_up = false
	
	for body in $"Top Area2D".get_overlapping_bodies():
		if body.is_in_group("object"):
			colliding_with_object_up = true
	
	if not (colliding_with_object_up and scale_dir.y > $Sprite.scale.y):
		$Sprite.scale = lerp($Sprite.scale, scale_dir, 0.15)
		
		$Camera2D.position = lerp($Camera2D.position, Vector2(0, -200) * scale_dir.y, 0.15)
	
	# Moving
	var input_vel_x = 0
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
	
	velocity.x = input_vel_x * speed
	
	jump = false
	if Input.is_action_pressed("jump"):
		jump = true

func update_collision_shapes():
	if Vector2(stepify($Sprite.scale.x, 0.01), stepify($Sprite.scale.y, 0.01)) != scale_dir: # So it's not unnecessarily run.
		for i in range(len($CollisionPolygon2D.polygon)):
			$CollisionPolygon2D.polygon[i].x = original_polygon[i].x * $Sprite.scale.x
			$CollisionPolygon2D.polygon[i].y = original_polygon[i].y * $Sprite.scale.y
		
		$CollisionPolygon2D.position = Vector2(0, -156) * $Sprite.scale # So the centre of enlargement is at the bottom of the middle of the sprite.
		
		for i in range(len($"Top Area2D/CollisionPolygon2D".polygon)):
			$"Top Area2D/CollisionPolygon2D".polygon[i].x = original_polygon_top[i].x * $Sprite.scale.x
			$"Top Area2D/CollisionPolygon2D".polygon[i].y = original_polygon_top[i].y * $Sprite.scale.y
		
		$"Top Area2D".position = Vector2(0, -300) * $Sprite.scale

func movement(delta):
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() and jump:
		velocity.y = -jump_speed

func animate():
	pass
