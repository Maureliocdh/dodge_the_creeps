extends CanvasLayer

signal start_game

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("GAME OVER")
	await $MessageTimer.timeout
	$MessageLabel.text = "☣ APOCALIPSIS\nDODGE"
	$MessageLabel.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func update_lives(lives: int):
	var hearts = ""
	for i in lives:
		hearts += "❤ "
	$LivesLabel.text = hearts.strip_edges()


func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()

