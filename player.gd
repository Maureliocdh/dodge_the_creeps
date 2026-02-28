extends Area2D

signal hit
@export var bullet_scene: PackedScene
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
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
		
		# Usamos la rotación actual del jugador para calcular la dirección
		# Vector2.UP.rotated(rotation) toma el vector "arriba" y lo gira lo que diga el jugador
		var spawn_direction = Vector2.UP.rotated(rotation)
		
		# Si el personaje está mirando a la izquierda (flip_h), forzamos dirección izquierda
		if $AnimatedSprite2D.animation == &"right" and $AnimatedSprite2D.flip_h:
			spawn_direction = Vector2.LEFT
		elif $AnimatedSprite2D.animation == &"right" and not $AnimatedSprite2D.flip_h:
			spawn_direction = Vector2.RIGHT

		bala.direction = spawn_direction
		# Rotamos la bala para que apunte a donde va
		bala.rotation = spawn_direction.angle() + PI/2

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	if has_shield:
		desactivate_shield()
		_body.queue_free()
	else:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
	

var has_shield = false

func activate_shield():
	has_shield = true
	$ShieldSprite.show()
	
func desactivate_shield():
	has_shield = false	
	$ShieldSprite.hide()
	
	
	
