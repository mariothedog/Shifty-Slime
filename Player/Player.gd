extends KinematicBody2D

# Main constants
const GRAVITY = 1200

# Movement constants
const SPEED = 300
const JUMP_SPEED = 400

# Expanding constants
const EXPANDING_SCALE = 0.7
const EXPANDING_LERP_WEIGHT = 0.15
const JUMP_EXPANDING_LERP_WEIGHT = 0.08

# Animation constants
const EYE_BASE_MOVEMENT_LERP_WEIGHT = 0.2
const EYE_MOVEMENT_LERP_WEIGHT = 0.3
const DEAD_SPLIT_ANIM_DURATION = 0.1
const MOVEMENT_ROTATION_DEGREES = 0.5
const LANDING_EXPANDING_SCALE = 0.55

# Main variables
var dead = false

# Movement variables
var velocity = Vector2()

# Expanding variables
var scale_dir := Vector2()

# Hitbox variables
onready var default_hitbox_left = $Left.polygon
onready var default_hitbox_right = $Right.polygon

# Jumping variables
var jump_held = false
var jump = false

# Animation variables
var elapsed_time = 0
var was_on_floor_last_frame = false
var impact_velocity = Vector2()

func _physics_process(delta) -> void:
	if not dead:
		elapsed_time += delta
		_get_general_input()
		_get_movement_input()
		_get_expanding_input()
		_get_jump_input()
		_default_animation()
		_expand_player()
		_expand_hitbox()
		_update_raycasts()
	_move(delta)
	_animate()

func _get_general_input() -> void:
	if Input.is_action_just_pressed("restart"):
		global.restart_level()

func _get_movement_input() -> void:
	var input_vel_x = 0
	
	if Input.is_action_pressed("move_right"):
		input_vel_x += 1
	
	if Input.is_action_pressed("move_left"):
		input_vel_x -= 1
	
	velocity.x = input_vel_x * SPEED

func _get_expanding_input() -> void:
	scale_dir = Vector2.ONE
	
	if Input.is_action_pressed("expand_up"):
		$Tween.remove_all()
		scale_dir += Vector2(-EXPANDING_SCALE, EXPANDING_SCALE)
	
	if Input.is_action_pressed("shrink"):
		$Tween.remove_all()
		scale_dir += Vector2(EXPANDING_SCALE, -EXPANDING_SCALE)

func _get_jump_input() -> void:
	jump = false
	if Input.is_action_pressed("jump"):
		jump_held = true
		scale_dir = Vector2(1 + EXPANDING_SCALE, 1 - EXPANDING_SCALE)
	
	if Input.is_action_just_released("jump"):
		jump_held = false
		if not Input.is_action_pressed("shrink"):
			jump = true

func _default_animation() -> void:
	var scale = sin(3 * elapsed_time)/20
	scale_dir.y = clamp(scale_dir.y + scale, 0.01, 1.99)
	scale_dir.x = clamp(scale_dir.x - scale, 0.01, 1.99)

func _expand_player() -> void:
	if not ($"RayCasts/Left RayCast".is_colliding() and scale_dir.x > $Sprites/Left.scale.x):
		$Sprites/Left.scale.x = lerp($Sprites/Left.scale.x, scale_dir.x, EXPANDING_LERP_WEIGHT)
	
	if not ($"RayCasts/Right RayCast".is_colliding() and scale_dir.x > $Sprites/Right.scale.x):
		$Sprites/Right.scale.x = lerp($Sprites/Right.scale.x, scale_dir.x, EXPANDING_LERP_WEIGHT)
	
	if $"RayCasts/Up RayCast".is_colliding() and scale_dir.y > $Sprites.scale.y:
		return
	
	if jump_held:
		$Sprites.scale.y = lerp($Sprites.scale.y, scale_dir.y, JUMP_EXPANDING_LERP_WEIGHT)
	else:
		$Sprites.scale.y = lerp($Sprites.scale.y, scale_dir.y, EXPANDING_LERP_WEIGHT)

func _expand_hitbox() -> void:
	for point in range(len(default_hitbox_left)):
		# Left CollisionPolygon2D
		$Left.polygon[point].x = default_hitbox_left[point].x * $Sprites/Left.scale.x
		$Left.polygon[point].y = default_hitbox_left[point].y * $Sprites.scale.y
		
		# Right CollisionPolygon2D
		$Right.polygon[point].x = default_hitbox_right[point].x * $Sprites/Right.scale.x
		$Right.polygon[point].y = default_hitbox_right[point].y * $Sprites.scale.y
	
	# So the centre of enlargement is at the bottom of the middle of the sprite.
	$Left.position.y = -8 * $Sprites.scale.y
	
	$Right.position.y = -8 * $Sprites.scale.y

func _update_raycasts() -> void:
	# Side RayCast2Ds
	$RayCasts.position = Vector2(0, -64) * $Sprites.scale.y
	
	$"RayCasts/Left RayCast".cast_to = Vector2(-100, 0) * $Sprites/Left.scale.x
	$"RayCasts/Right RayCast".cast_to = Vector2(100, 0) * $Sprites/Right.scale.x
	
	# Up RayCast2D
	$"RayCasts/Up RayCast".cast_to = Vector2(0, -85) * $Sprites.scale.y
	
	# Down RayCast2Ds
	$"Down RayCasts".position = Vector2(0, -64) * $Sprites.scale.y
	
	$"Down RayCasts/RayCast".cast_to = Vector2(0, 60) * $Sprites.scale.y
	
	if $Sprites/Left.scale.x > 0.8:
		$"Down RayCasts/RayCast2".enabled = true
		$"Down RayCasts/RayCast2".cast_to = Vector2(0, 60) * $Sprites.scale.y
	else:
		$"Down RayCasts/RayCast2".enabled = false
	
	if $Sprites/Left.scale.x > 1.2:
		$"Down RayCasts/RayCast4".enabled = true
		$"Down RayCasts/RayCast4".cast_to = Vector2(0, 60) * $Sprites.scale.y
	else:
		$"Down RayCasts/RayCast4".enabled = false
		
	if $Sprites/Right.scale.x > 0.8:
		$"Down RayCasts/RayCast3".enabled = true
		$"Down RayCasts/RayCast3".cast_to = Vector2(0, 60) * $Sprites.scale.y
	else:
		$"Down RayCasts/RayCast3".enabled = false
	
	if $Sprites/Right.scale.x > 1.2:
		$"Down RayCasts/RayCast5".enabled = true
		$"Down RayCasts/RayCast5".cast_to = Vector2(0, 60) * $Sprites.scale.y
	else:
		$"Down RayCasts/RayCast5".enabled = false

func _move(delta) -> void:
	velocity.y += GRAVITY * pow($Sprites.scale.y, 1.1) * delta
	
	var vel = move_and_slide(velocity, Vector2.UP)
	
	if not _is_player_on_floor():
		impact_velocity = velocity
	
	velocity = vel
	
	if _is_player_on_floor() and jump:
		_jump()

func _is_player_on_floor() -> bool:
	for rayCast in $"Down RayCasts".get_children():
		if rayCast.is_colliding():
			return true
	
	return false

func _jump() -> void:
	velocity.y = -JUMP_SPEED * (1/$Sprites.scale.y)

func _animate() -> void:
	# Camera animation
	$Camera2D.position = lerp($Camera2D.position, Vector2(0, -200) * $Sprites.scale.y, 0.15)
	
	if dead:
		return
	
	# Landing animation
	if not was_on_floor_last_frame and _is_player_on_floor() and impact_velocity.y > 400 and not $Tween.is_active():
		var final_scale = Vector2(clamp(1 + LANDING_EXPANDING_SCALE * impact_velocity.y / 1400, 0.01, 1.99),
		clamp(1 - LANDING_EXPANDING_SCALE * impact_velocity.y / 1400, 0.3, 1.99))
		
		if $Sprites.scale.y < final_scale.y:
			final_scale = Vector2($Sprites.scale.x + 0.15, $Sprites.scale.y - 0.15)
		
		$Tween.interpolate_property($Sprites, "scale", $Sprites.scale,
		Vector2($Sprites.scale.x, final_scale.y), 200/impact_velocity.y,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		
		$Tween.start()
		
		$Tween.interpolate_property($Sprites/Left, "scale", $Sprites/Left.scale,
		Vector2(final_scale.x, $Sprites/Left.scale.y), 200/impact_velocity.y,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		
		$Tween.start()
		
		$Tween.interpolate_property($Sprites/Right, "scale", $Sprites/Right.scale,
		Vector2(final_scale.x, $Sprites/Right.scale.y), 200/impact_velocity.y,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		
		$Tween.start()
	
	was_on_floor_last_frame = _is_player_on_floor()
	
	# Eye animation
	$Eyes.position.y = -120 * $Sprites.scale.y
	
	if abs(velocity.x) > 0:
		if velocity.x > 0: # Moving right
			$Eyes.position.x = lerp($Eyes.position.x, 40 * $Sprites/Left.scale.x, EYE_BASE_MOVEMENT_LERP_WEIGHT)
			rotation_degrees = MOVEMENT_ROTATION_DEGREES
		else: # Moving left
			$Eyes.position.x = lerp($Eyes.position.x, -40 * $Sprites/Left.scale.x, EYE_BASE_MOVEMENT_LERP_WEIGHT)
			rotation_degrees = -MOVEMENT_ROTATION_DEGREES
	else:
		$Eyes.position.x = lerp($Eyes.position.x, 0, EYE_BASE_MOVEMENT_LERP_WEIGHT)
	
	# Clamp it to inside the elliptic eye boundary
	var final_left_eye_pos = ($"Eyes/Left Eye Base".get_local_mouse_position() / Vector2(20, 30)).clamped(1) * Vector2(20, 30)
	var final_right_eye_pos = ($"Eyes/Right Eye Base".get_local_mouse_position() / Vector2(20, 30)).clamped(1) * Vector2(20, 30)
	
	$"Eyes/Left Eye Base/Pupil".position = lerp($"Eyes/Left Eye Base/Pupil".position, final_left_eye_pos, EYE_MOVEMENT_LERP_WEIGHT)
	$"Eyes/Right Eye Base/Pupil".position = lerp($"Eyes/Right Eye Base/Pupil".position, final_right_eye_pos, EYE_MOVEMENT_LERP_WEIGHT)

func kill():
	dead = true
	
	velocity.x = 0
	
	# Play death animation
	$Tween.interpolate_property($"Sprites/Left", "position",
	$Sprites/Left.position, $Sprites/Left.position + Vector2(-25, 0),
	DEAD_SPLIT_ANIM_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	$Tween.interpolate_property($"Sprites/Right", "position",
	$Sprites/Right.position, $Sprites/Right.position + Vector2(25, 0),
	DEAD_SPLIT_ANIM_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	$Tween.interpolate_property($"Eyes/Left Eye Base", "position",
	$"Eyes/Left Eye Base".position, $"Eyes/Left Eye Base".position + Vector2(-25, 0) * ($Sprites.scale.x * 0.9),
	DEAD_SPLIT_ANIM_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	$Tween.interpolate_property($"Eyes/Right Eye Base", "position",
	$"Eyes/Right Eye Base".position, $"Eyes/Right Eye Base".position + Vector2(25, 0) * ($Sprites.scale.x * 0.9),
	DEAD_SPLIT_ANIM_DURATION, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	$Tween.interpolate_property(self, "modulate",
	modulate, Color(1, 1, 1, 0), 1)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	global.restart_level()

func _on_Spawning_Particles_Timer_timeout():
	$"Spawn Particles".emitting = false
