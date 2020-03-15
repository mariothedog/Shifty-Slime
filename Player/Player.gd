extends KinematicBody2D

export var speed = 300
export var jump_speed = 400
export var expanding_scale = 0.65
export var moving_rotation_normal = 2
export var moving_rotation_short = 0.5
export var moving_rotation_tall = 4

const GRAVITY = 1200

var velocity = Vector2()

var scale_dir = Vector2(1, 1)

var jump = false
var jump_held = false

onready var original_polygon = $CollisionPolygon2D.polygon
onready var original_polygon_top = $"Detectors/Top Area2D/CollisionPolygon2D".polygon
onready var original_polygon_left = $"Detectors/Left Area2D/Left".polygon
onready var original_polygon_right = $"Detectors/Right Area2D/Right".polygon

onready var collision_polygon_default_pos = $CollisionPolygon2D.position
onready var top_area_default_pos = $"Detectors/Top Area2D".position
onready var left_area_default_pos = $"Detectors/Left Area2D/Left".position
onready var right_area_default_pos = $"Detectors/Right Area2D/Right".position
onready var eyes_default_pos = $Eyes.position
onready var eye_default_pos = $"Eyes/Right Eye Base".position

onready var texture_height = $Sprite.texture.get_height()
onready var texture_width = $Sprite.texture.get_width()
onready var bottom_offset = Vector2(0, -texture_height/2)
onready var left_offset = Vector2(texture_width/2, -texture_height/2)
onready var right_offset = Vector2(-texture_width/2, -texture_height/2)

func _ready():
	update_raycasts()

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
	
	if Input.is_action_pressed("shrink"):
		scale_dir += Vector2(expanding_scale, -expanding_scale)
	
	var can_scale = true
	if (($"Detectors/Left Area2D".get_overlapping_bodies() and $"Detectors/Right Area2D".get_overlapping_bodies()) or
	($"Detectors/Top Area2D".get_overlapping_bodies() and scale_dir.y > $Sprite.scale.y)):
		can_scale = false
	elif $"Detectors/Left Area2D".get_overlapping_bodies():
		$Sprite.offset = left_offset
		$Sprite.position.x = -left_offset.x * $Sprite.scale.x
	elif $"Detectors/Right Area2D".get_overlapping_bodies():
		$Sprite.offset = right_offset
		$Sprite.position.x = -right_offset.x * $Sprite.scale.x
	else:
		$Sprite.offset = bottom_offset
		$Sprite.position.x = 0
	
	if can_scale and not jump_held:
		$Sprite.scale = lerp($Sprite.scale, scale_dir, 0.15)
	
	$Camera2D.position = lerp($Camera2D.position, Vector2(0, -200) * $Sprite.scale.y, 0.15)
	
	$Eyes.position.y = eyes_default_pos.y * $Sprite.scale.y
	
	# Moving
	var input_vel_x = 0
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
		
		if $Sprite.scale.x > 1:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_short, 0.15)
		elif $Sprite.scale.x < 1:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_tall, 0.15)
		else:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_normal, 0.15)
		
		$Eyes.position.x = lerp($Eyes.position.x, eye_default_pos.x * $Sprite.scale.x, 0.2)
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
		
		if $Sprite.scale.x > 1:
			rotation_degrees = lerp(rotation_degrees, -moving_rotation_short, 0.15)
		elif $Sprite.scale.x < 1:
			rotation_degrees = lerp(rotation_degrees, -moving_rotation_tall, 0.15)
		else:
			rotation_degrees = lerp(rotation_degrees, -moving_rotation_normal, 0.15)
		
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
		jump_held = false
		if not Input.is_action_pressed("shrink"):
			jump = true

func update_collision_shapes():
	if stepify_vector($Sprite.scale, 0.01) != scale_dir: # So it's not unnecessarily run.
		for i in range(len($CollisionPolygon2D.polygon)):
			$CollisionPolygon2D.polygon[i].x = original_polygon[i].x * $Sprite.scale.x
			$CollisionPolygon2D.polygon[i].y = original_polygon[i].y * $Sprite.scale.y
		
		$CollisionPolygon2D.position = collision_polygon_default_pos * $Sprite.scale # So the centre of enlargement is at the bottom of the middle of the sprite.
		
		for i in range(len($"Detectors/Top Area2D/CollisionPolygon2D".polygon)):
			$"Detectors/Top Area2D/CollisionPolygon2D".polygon[i].x = original_polygon_top[i].x * $Sprite.scale.x
			$"Detectors/Top Area2D/CollisionPolygon2D".polygon[i].y = original_polygon_top[i].y * $Sprite.scale.y
		
		$"Detectors/Top Area2D".position = top_area_default_pos * $Sprite.scale
		
		for i in range(len($"Detectors/Left Area2D/Left".polygon)):
			$"Detectors/Left Area2D/Left".polygon[i].x = original_polygon_left[i].x * $Sprite.scale.x
			$"Detectors/Left Area2D/Left".polygon[i].y = original_polygon_left[i].y * $Sprite.scale.y
		
		$"Detectors/Left Area2D/Left".position = left_area_default_pos * $Sprite.scale
		
		for i in range(len($"Detectors/Right Area2D/Right".polygon)):
			$"Detectors/Right Area2D/Right".polygon[i].x = original_polygon_right[i].x * $Sprite.scale.x
			$"Detectors/Right Area2D/Right".polygon[i].y = original_polygon_right[i].y * $Sprite.scale.y
		
		$"Detectors/Right Area2D/Right".position = right_area_default_pos * $Sprite.scale
		
		update_raycasts()

func movement(delta):
	velocity.y += GRAVITY * (1 / $Sprite.scale.x) * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var is_touching_floor = false
	for raycast in $"Detectors/Floor Detector".get_children():
		if raycast.is_colliding():
			is_touching_floor = true
	
	if is_touching_floor and jump:
		velocity.y = -jump_speed * pow($Sprite.scale.x, 1.8)

func animate():
	#$"Eyes/Left Eye Base/Pupil".look_at(get_global_mouse_position())
	#$"Eyes/Right Eye Base/Pupil".look_at(get_global_mouse_position())
	
#	$"Eyes/Left Eye Base/Pupil".rotation = lerp_angle($"Eyes/Left Eye Base/Pupil".rotation, $"Eyes/Left Eye Base/Pupil".global_position.angle_to_point(get_global_mouse_position()) + PI, 0.4)
#	$"Eyes/Right Eye Base/Pupil".rotation = lerp_angle($"Eyes/Right Eye Base/Pupil".rotation, $"Eyes/Right Eye Base/Pupil".global_position.angle_to_point(get_global_mouse_position()) + PI, 0.4)
#	print($"Eyes/Left Eye Base/Pupil".offset)
	
	var final_pos_left = Vector2(max(min(get_global_mouse_position().x, $"Eyes/Left Eye Base".global_position.x + 20), $"Eyes/Left Eye Base".global_position.x - 20),
	max(min(get_global_mouse_position().y, $"Eyes/Left Eye Base".global_position.y + 30), $"Eyes/Left Eye Base".global_position.y - 30))
	
	var final_pos_right = Vector2(max(min(get_global_mouse_position().x, $"Eyes/Right Eye Base".global_position.x + 20), $"Eyes/Right Eye Base".global_position.x - 20),
	max(min(get_global_mouse_position().y, $"Eyes/Right Eye Base".global_position.y + 30), $"Eyes/Right Eye Base".global_position.y - 30))
	
	$"Eyes/Left Eye Base/Pupil".global_position = lerp($"Eyes/Left Eye Base/Pupil".global_position, final_pos_left, 0.4)
	$"Eyes/Right Eye Base/Pupil".global_position = lerp($"Eyes/Right Eye Base/Pupil".global_position, final_pos_right, 0.4)

func stepify_vector(vector, step):
	return Vector2(stepify(vector.x, step), stepify(vector.y, step))

func update_raycasts():
	for raycast in $"Detectors/Floor Detector".get_children():
			raycast.enabled = true
	
	if $Sprite.scale.x <= 1.2:
		$"Detectors/Floor Detector/RayCast2D6".enabled = false
		$"Detectors/Floor Detector/RayCast2D7".enabled = false
		$"Detectors/Floor Detector/RayCast2D8".enabled = false
		$"Detectors/Floor Detector/RayCast2D9".enabled = false
	
	if $Sprite.scale.x <= 0.7:
		$"Detectors/Floor Detector/RayCast2D4".enabled = false
		$"Detectors/Floor Detector/RayCast2D5".enabled = false
	
	if $Sprite.scale.x <= 0.6:
		$"Detectors/Floor Detector/RayCast2D2".enabled = false
		$"Detectors/Floor Detector/RayCast2D3".enabled = false
