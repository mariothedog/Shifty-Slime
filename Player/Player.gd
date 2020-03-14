extends KinematicBody2D

export var speed = 300
export var jump_speed = 400
export var expanding_scale = 0.65
export var moving_rotation = 5

const GRAVITY = 700

var velocity = Vector2()

var scale_dir = Vector2(1, 1)

var jump = false
var jump_held = false

onready var original_polygon = $CollisionPolygon2D.polygon
onready var original_polygon_top = $"Top Area2D/CollisionPolygon2D".polygon
onready var original_polygon_right = $"Side Area2D/Right".polygon
onready var original_polygon_left = $"Side Area2D/Left".polygon

onready var collision_polygon_default_pos = $CollisionPolygon2D.position
onready var top_area_default_pos = $"Top Area2D".position
onready var side_area_right_default_pos = $"Side Area2D/Right".position
onready var side_area_left_default_pos = $"Side Area2D/Left".position
onready var eyes_default_pos = $Eyes.position
onready var eye_default_pos = $"Eyes/Right Eye Base".position

func _physics_process(delta):
	scale_dir = Vector2(1, 1)
	input()
	update_collision_shapes()
	movement(delta)
	animate()

func input():
	# Growing
	if Input.is_action_pressed("expand_up"):
		scale_dir += Vector2(-expanding_scale, expanding_scale)
	
	var colliding_with_object_up = false
	for body in $"Top Area2D".get_overlapping_bodies():
		if body.is_in_group("object"):
			colliding_with_object_up = true
	
	var colliding_with_object_side = false
	for body in $"Side Area2D".get_overlapping_bodies():
		if body.is_in_group("object"):
			colliding_with_object_side = true
	
	if (not (colliding_with_object_up and scale_dir.y > $Sprite.scale.y or
	colliding_with_object_side and scale_dir.x > $Sprite.scale.x) and
	not jump_held):
		$Sprite.scale = lerp($Sprite.scale, scale_dir, 0.15)
		
	$Camera2D.position = lerp($Camera2D.position, Vector2(0, -200) * $Sprite.scale.y, 0.15)
	
	$Eyes.position.y = eyes_default_pos.y * $Sprite.scale.y
	
	# Moving
	var input_vel_x = 0
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
		
		if scale_dir.x > 1:
			rotation_degrees = lerp(rotation_degrees, moving_rotation - 6 * (1 / scale_dir.x), 0.15)
		elif scale_dir.x < 1:
			rotation_degrees = lerp(rotation_degrees, moving_rotation + 0.5 * (1 / scale_dir.x), 0.15)
		else:
			rotation_degrees = lerp(rotation_degrees, moving_rotation, 0.15)
		
		$Eyes.position.x = lerp($Eyes.position.x, eye_default_pos.x * $Sprite.scale.x, 0.2)
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
		
		if scale_dir.x > 1:
			rotation_degrees = lerp(rotation_degrees, -(moving_rotation - 6 * (1 / scale_dir.x)), 0.15)
		elif scale_dir.x < 1:
			rotation_degrees = lerp(rotation_degrees, -(moving_rotation + 0.5 * (1 / scale_dir.x)), 0.15)
		else:
			rotation_degrees = lerp(rotation_degrees, -moving_rotation, 0.15)
		
		$Eyes.position.x = lerp($Eyes.position.x, -eye_default_pos.x * $Sprite.scale.x, 0.2)
	
	if input_vel_x == 0:
		rotation_degrees = lerp(rotation_degrees, 0, 0.15)
		
		$Eyes.position.x = lerp($Eyes.position.x, 0, 0.2)
	
	velocity.x = input_vel_x * speed
	
	jump = false
	if Input.is_action_pressed("jump"):
		jump_held = true
		$Sprite.scale = lerp($Sprite.scale, Vector2(1 + expanding_scale, 1 - expanding_scale), 0.08)
	
	if Input.is_action_just_released("jump"):
		jump = true
		jump_held = false

func update_collision_shapes():
	if stepify_vector($Sprite.scale, 0.01) != scale_dir: # So it's not unnecessarily run.
		for i in range(len($CollisionPolygon2D.polygon)):
			$CollisionPolygon2D.polygon[i].x = original_polygon[i].x * $Sprite.scale.x
			$CollisionPolygon2D.polygon[i].y = original_polygon[i].y * $Sprite.scale.y
		
		$CollisionPolygon2D.position = collision_polygon_default_pos * $Sprite.scale # So the centre of enlargement is at the bottom of the middle of the sprite.
		
		for i in range(len($"Top Area2D/CollisionPolygon2D".polygon)):
			$"Top Area2D/CollisionPolygon2D".polygon[i].x = original_polygon_top[i].x * $Sprite.scale.x
			$"Top Area2D/CollisionPolygon2D".polygon[i].y = original_polygon_top[i].y * $Sprite.scale.y
		
		$"Top Area2D".position = top_area_default_pos * $Sprite.scale
		
		for i in range(len($"Side Area2D/Right".polygon)):
			$"Side Area2D/Right".polygon[i].x = original_polygon_right[i].x * $Sprite.scale.x
			$"Side Area2D/Right".polygon[i].y = original_polygon_right[i].y * $Sprite.scale.y
		
		$"Side Area2D/Right".position = side_area_right_default_pos * $Sprite.scale
		
		for i in range(len($"Side Area2D/Left".polygon)):
			$"Side Area2D/Left".polygon[i].x = original_polygon_left[i].x * $Sprite.scale.x
			$"Side Area2D/Left".polygon[i].y = original_polygon_left[i].y * $Sprite.scale.y
		
		$"Side Area2D/Left".position = side_area_left_default_pos * $Sprite.scale

func movement(delta):
	velocity.y += GRAVITY * (1 / $Sprite.scale.x) * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() and jump:
		velocity.y = -jump_speed * pow($Sprite.scale.x, 1.8)

func animate():
	$"Eyes/Left Eye Base/Pupil".look_at(get_global_mouse_position())
	$"Eyes/Right Eye Base/Pupil".look_at(get_global_mouse_position())
	
func stepify_vector(vector, step):
	return Vector2(stepify(vector.x, step), stepify(vector.y, step))
