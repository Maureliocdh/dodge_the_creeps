extends Node

@export var shield_scene: PackedScene
@export var mob_scene: PackedScene

var score
var lives := 3

var _hit_sound: AudioStreamPlayer
var _pickup_sound: AudioStreamPlayer


func _ready():
	_setup_sounds()
	_setup_background_fx()


func _setup_sounds():
	# Reutiliza el stream del DeathSound con diferentes tonos para más efectos
	_hit_sound = AudioStreamPlayer.new()
	_hit_sound.stream = $DeathSound.stream
	_hit_sound.pitch_scale = 1.8
	_hit_sound.volume_db = -4
	_hit_sound.name = "HitSound"
	add_child(_hit_sound)

	_pickup_sound = AudioStreamPlayer.new()
	_pickup_sound.stream = $DeathSound.stream
	_pickup_sound.pitch_scale = 4.5
	_pickup_sound.volume_db = -4
	_pickup_sound.name = "PickupSound"
	add_child(_pickup_sound)


func _setup_background_fx():
	# Partículas de brasa/ceniza cayendo — efecto apocalíptico
	var embers = CPUParticles2D.new()
	embers.name = "Embers"
	embers.amount = 55
	embers.lifetime = 9.0
	embers.speed_scale = 0.9
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	embers.emission_rect_extents = Vector2(240, 2)
	embers.direction = Vector2(0.15, 1.0)
	embers.spread = 20.0
	embers.initial_velocity_min = 18.0
	embers.initial_velocity_max = 55.0
	embers.gravity = Vector2(3.0, 18.0)
	embers.scale_amount_min = 1.5
	embers.scale_amount_max = 4.5
	embers.color = Color(1.0, 0.38, 0.06, 0.75)
	embers.position = Vector2(240, -10)
	embers.z_index = -1
	add_child(embers)

	# Pulso rojo suave de fondo — atmósfera de peligro
	var overlay = ColorRect.new()
	overlay.name = "DangerOverlay"
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.grow_horizontal = 2
	overlay.grow_vertical = 2
	overlay.color = Color(0.55, 0.0, 0.0, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 5
	$CanvasLayer.add_child(overlay)
	var pulse = create_tween().set_loops()
	pulse.tween_property(overlay, "color:a", 0.07, 1.2)
	pulse.tween_property(overlay, "color:a", 0.0, 1.2)


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	$PowerupTimer.stop()
	get_tree().call_group(&"powerups", &"queue_free")


func new_game():
	lives = 3
	get_tree().call_group(&"mobs", &"queue_free")
	get_tree().call_group(&"powerups", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_lives(lives)
	$HUD.show_message("¡SOBREVIVE!")
	$Music.play()
	$PowerupTimer.start()


func _on_MobTimer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	# Aumenta la dificultad: enemigos más rápidos cada 20 puntos
	if score % 20 == 0 and $MobTimer.wait_time > 0.2:
		$MobTimer.wait_time = max(0.2, $MobTimer.wait_time - 0.05)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_powerup_timer_timeout() -> void:
	var r = randi() % 3
	match r:
		0:
			if shield_scene:
				var shield = shield_scene.instantiate()
				shield.add_to_group(&"powerups")
				shield.position = Vector2(randf_range(50, 430), randf_range(50, 650))
				add_child(shield)
		1:
			_spawn_speed_powerup()
		2:
			_spawn_life_powerup()


func _spawn_speed_powerup():
	var area = Area2D.new()
	area.add_to_group(&"powerups")
	area.position = Vector2(randf_range(50, 430), randf_range(50, 650))

	var bg = ColorRect.new()
	bg.size = Vector2(52, 52)
	bg.position = Vector2(-26, -26)
	bg.color = Color(1.0, 0.85, 0.0, 0.92)
	area.add_child(bg)

	var lbl = Label.new()
	lbl.text = "⚡"
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.position = Vector2(-20, -26)
	area.add_child(lbl)

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 26.0
	col.shape = shape
	area.add_child(col)

	# Pulso de escala
	var tw = area.create_tween().set_loops()
	tw.tween_property(area, "scale", Vector2(1.15, 1.15), 0.4)
	tw.tween_property(area, "scale", Vector2(1.0, 1.0), 0.4)

	area.area_entered.connect(func(other): _on_speed_powerup_picked(other, area))
	add_child(area)
	get_tree().create_timer(12.0).timeout.connect(func(): if is_instance_valid(area): area.queue_free())


func _on_speed_powerup_picked(other_area, powerup):
	if other_area.name == "Player":
		other_area.activate_speed_boost()
		play_powerup_sound()
		powerup.queue_free()


func _spawn_life_powerup():
	var area = Area2D.new()
	area.add_to_group(&"powerups")
	area.position = Vector2(randf_range(50, 430), randf_range(50, 650))

	var bg = ColorRect.new()
	bg.size = Vector2(52, 52)
	bg.position = Vector2(-26, -26)
	bg.color = Color(0.9, 0.1, 0.2, 0.92)
	area.add_child(bg)

	var lbl = Label.new()
	lbl.text = "❤"
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.position = Vector2(-19, -25)
	area.add_child(lbl)

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 26.0
	col.shape = shape
	area.add_child(col)

	var tw = area.create_tween().set_loops()
	tw.tween_property(area, "scale", Vector2(1.15, 1.15), 0.5)
	tw.tween_property(area, "scale", Vector2(1.0, 1.0), 0.5)

	area.area_entered.connect(func(other): _on_life_powerup_picked(other, area))
	add_child(area)
	get_tree().create_timer(12.0).timeout.connect(func(): if is_instance_valid(area): area.queue_free())


func _on_life_powerup_picked(other_area, powerup):
	if other_area.name == "Player":
		add_life()
		play_powerup_sound()
		powerup.queue_free()


func add_life():
	if lives < 5:
		lives += 1
		$HUD.update_lives(lives)


func play_hit_sound():
	if is_instance_valid(_hit_sound):
		_hit_sound.play()


func play_powerup_sound():
	if is_instance_valid(_pickup_sound):
		_pickup_sound.play()


func _input(event):
	if event.is_action_pressed("ui_cancel") or Input.is_key_pressed(KEY_P):
		var estado_actual = get_tree().paused
		get_tree().paused = !estado_actual
		$CanvasLayer/menupausa.visible = !estado_actual


func _on_player_hit() -> void:
	lives -= 1
	$HUD.update_lives(lives)
	play_hit_sound()
	if lives <= 0:
		$PowerupTimer.stop()
		game_over()
	else:
		$HUD.show_message("❤ " + str(lives) + " vidas")
		await get_tree().create_timer(0.4).timeout
		$Player.respawn($StartPosition.position)

