extends KinematicBody2D

const GRAVITY = 1200

const SPEED = 200

var velocity := Vector2()

var dead = false

func _ready():
	velocity.x = SPEED * sign(rand_range(-1, 1))

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if not dead:
		velocity = move_and_slide(velocity)
		
		if $"Wall Detector".is_colliding():
			velocity.x *= -1
			$"Wall Detector".cast_to *= -1

func _on_Attack_Hitbox_body_entered(body):
	if body.get_node("Sprites").scale.y > 1.5:
		_die()
	else:
		body.kill()

func _die():
	dead = true
	
	velocity.x = 0
	
	$CollisionPolygon2D.set_deferred("disabled", true)
	$"Attack Hitbox/CollisionShape2D".set_deferred("disabled", true)
	
	# Play death animation
	$Tween.interpolate_property($"Sprites/Left", "position",
	$Sprites/Left.position, $Sprites/Left.position + Vector2(-25, 0),
	0.1, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	$Tween.interpolate_property($"Sprites/Right", "position",
	$Sprites/Right.position, $Sprites/Right.position + Vector2(25, 0),
	0.1, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	$Tween.interpolate_property(self, "modulate",
	modulate, Color(1, 1, 1, 0), 1)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	
	queue_free()
