extends RigidBody2D

func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	var chosen = mob_types.pick_random()
	$AnimatedSprite2D.animation = chosen
	$AnimatedSprite2D.play()

	# Different speed and appearance per enemy type
	match chosen:
		"fly":
			# Volador rapido — rojo sangre
			linear_velocity *= 1.9
			modulate = Color(1.2, 0.5, 0.5)
			$AnimatedSprite2D.scale *= 0.85
		"swim":
			# Lento pero grande — azul toxido
			linear_velocity *= 0.65
			modulate = Color(0.5, 0.9, 1.2)
			$AnimatedSprite2D.scale *= 1.25
		"walk":
			# Caminante normal — verde putrefacto
			modulate = Color(0.6, 1.1, 0.6)
		"zombie":
			# Zombie clasico — muy rapido y pequeño
			linear_velocity *= 2.2
			modulate = Color(0.8, 1.0, 0.5)
			$AnimatedSprite2D.scale *= 0.7


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
