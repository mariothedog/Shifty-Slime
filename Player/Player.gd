extends KinematicBody2D

const speed = 300
const jump_speed = 400
const expanding_scale = 0.65
const landing_expanding_scale = 0.55
const moving_rotation_normal = 2
const moving_rotation_short = 0.5
const moving_rotation_tall = 4
const GRAVITY = 1200

var velocity = Vector2()

var scale_dir = Vector2(1, 1)

var jump = false
var jump_held = false
var is_touching_floor = false
var was_on_floor_last_frame = false
var impact_velocity = Vector2()
var time_since_last_landing_anim = 0

var elapsed_time = 0

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
	elapsed_time += delta
	input()
	update_collision_shapes()
	movement(delta)
	animate(delta)

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
	
	if can_scale and not jump_held and not $Tween.is_active():
		# Default animation
		var scale = sin(3 * elapsed_time)/20
		scale_dir.y += scale
		scale_dir.x -= scale
	
		# Expand/shrink the player
		$Sprite.scale = lerp($Sprite.scale, scale_dir, 0.15)
	
	$Camera2D.position = lerp($Camera2D.position, Vector2(0, -200) * $Sprite.scale.y, 0.15)
	
	$Eyes.position.y = eyes_default_pos.y * $Sprite.scale.y
	
	# Moving
	var input_vel_x = 0
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
		
		if $Sprite.scale.x > 1.1:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_short, 0.15)
		elif $Sprite.scale.x < 0.9:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_tall, 0.15)
		else:
			rotation_degrees = lerp(rotation_degrees, moving_rotation_normal, 0.15)
		
		$Eyes.position.x = lerp($Eyes.position.x, eye_default_pos.x * $Sprite.scale.x, 0.2)
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
		
		if $Sprite.scale.x > 1.1:
			rotation_degrees = lerp(rotation_degrees, -moving_rotation_short, 0.15)
		elif $Sprite.scale.x < 0.9:
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
	
	var vel = move_and_slide(velocity, Vector2.UP)
	
	is_touching_floor = false
	for raycast in $"Detectors/Floor Detector".get_children():
		if raycast.is_colliding():
			is_touching_floor = true
	
	if not is_touching_floor:
		impact_velocity = velocity
	
	velocity = vel
	
	if is_touching_floor and jump:
		velocity.y = -jump_speed * pow($Sprite.scale.x, 1.8)

func animate(delta):
	# Clamps it to inside the elliptic eye boundary
	var final_left_eye_pos = ($"Eyes/Left Eye Base".get_local_mouse_position() / Vector2(20, 30)).clamped(1) * Vector2(20, 30)
	var final_right_eye_pos = ($"Eyes/Right Eye Base".get_local_mouse_position() / Vector2(20, 30)).clamped(1) * Vector2(20, 30)
	
	$"Eyes/Left Eye Base/Pupil".position = lerp($"Eyes/Left Eye Base/Pupil".position, final_left_eye_pos, 0.4)
	$"Eyes/Right Eye Base/Pupil".position = lerp($"Eyes/Right Eye Base/Pupil".position, final_right_eye_pos, 0.4)
	
	# Landing animation
	if not was_on_floor_last_frame and is_touching_floor and impact_velocity.y > 400 and not $Tween.is_active() and time_since_last_landing_anim > 0.4:
		var final_scale = Vector2(1 + clamp(landing_expanding_scale * impact_velocity.y / 1400, 0.1, 0.9),
		1 - clamp(landing_expanding_scale * impact_velocity.y / 1400, 0.1, 0.9))
		
		if $Sprite.scale.y < final_scale.y:
			final_scale = Vector2($Sprite.scale.x + 0.15, $Sprite.scale.y - 0.15)
		
		$Tween.interpolate_property($Sprite, "scale", $Sprite.scale,
		final_scale, 200/impact_velocity.y,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		
		$Tween.start()
		
		time_since_last_landing_anim = 0
	else:
		time_since_last_landing_anim += delta
	
	was_on_floor_last_frame = is_touching_floor
	
func stepify_vector(vector, step):
	return Vector2(stepify(vector.x, step), stepify(vector.y, step))

func update_raycasts():
	for raycast in $"Detectors/Floor Detector".get_children():
			raycast.enabled = true
	
	if $Sprite.scale.x <= 1.2:
		$"Detectors/Floor Detector/RayCast2D6".enabled = false
		$"Detectors/Floor Detector/RayCast2D7".enabled = false
	
	if $Sprite.scale.x <= 0.7:
		$"Detectors/Floor Detector/RayCast2D4".enabled = false
		$"Detectors/Floor Detector/RayCast2D5".enabled = false
	
	if $Sprite.scale.x <= 0.6:
		$"Detectors/Floor Detector/RayCast2D2".enabled = false
		$"Detectors/Floor Detector/RayCast2D3".enabled = false
