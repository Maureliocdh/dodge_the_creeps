extends Node
@export var shield_scene: PackedScene

@export var mob_scene: PackedScene
var score

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	$PowerupTimer.stop()
	


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()
	$PowerupTimer.start()


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	
	


func _on_powerup_timer_timeout() -> void:
	var shield = shield_scene.instantiate()
	# Genera una posición aleatoria dentro de la pantalla
	shield.position = Vector2(randf_range(0, 480), randf_range(0, 720)) 
	add_child(shield)
	
	pass # Replace with function body.


func _input(event):
	# Si presionas la tecla ESC o P
	if event.is_action_pressed("ui_cancel") or Input.is_key_pressed(KEY_P):
		var estado_actual = get_tree().paused
		get_tree().paused = !estado_actual # Cambia de pausa a juego y viceversa
		$CanvasLayer/menupausa.visible = !estado_actual # Muestra u oculta el fondo negro
		
func _on_player_hit() -> void:
	game_over()
	$PowerupTimer.stop()
	
