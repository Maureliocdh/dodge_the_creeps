extends Area2D

signal hit
@export var bullet_scene: PackedScene
@export var speed = 400
var screen_size

var invincible = false
var has_shield = false
var speed_boost_active = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		if velocity.y > 0:
			rotation = PI
		else:
			rotation = 0

	if Input.is_action_just_pressed("ui_accept"):
		shoot()


func shoot():
	if bullet_scene:
		var bala = bullet_scene.instantiate()
		get_parent().add_child(bala)
		bala.position = position
		var spawn_direction = Vector2.UP.rotated(rotation)
		if $AnimatedSprite2D.animation == &"right" and $AnimatedSprite2D.flip_h:
			spawn_direction = Vector2.LEFT
		elif $AnimatedSprite2D.animation == &"right" and not $AnimatedSprite2D.flip_h:
			spawn_direction = Vector2.RIGHT
		bala.direction = spawn_direction
		bala.rotation = spawn_direction.angle() + PI/2


func start(pos):
	position = pos
	rotation = 0
	invincible = false
	speed_boost_active = false
	speed = 400
	modulate = Color(1, 1, 1)
	$AnimatedSprite2D.modulate.a = 1.0
	show()
	$CollisionShape2D.disabled = false


func respawn(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.set_deferred(&"disabled", false)
	invincible = true
	# Parpadeo de invencibilidad durante 2 segundos
	var tween = create_tween().set_loops(10)
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.15, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(2.0).timeout
	invincible = false
	$AnimatedSprite2D.modulate.a = 1.0


func activate_shield():
	has_shield = true
	$ShieldSprite.show()


func desactivate_shield():
	has_shield = false
	$ShieldSprite.hide()


func activate_speed_boost():
	if speed_boost_active:
		return
	speed_boost_active = true
	speed = 800
	modulate = Color(1.0, 1.0, 0.3)
	# Partícula de velocidad
	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_callback(func():
		speed = 400
		speed_boost_active = false
		modulate = Color(1, 1, 1)
	)


func _on_body_entered(_body):
	if invincible:
		return
	if has_shield:
		desactivate_shield()
		_body.queue_free()
	else:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
