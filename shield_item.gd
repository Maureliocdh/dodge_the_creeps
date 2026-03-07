extends Area2D

func _ready() -> void:
	# Pulso visual para el escudo
	var tw = create_tween().set_loops()
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.45)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.45)


func _process(_delta: float) -> void:
	pass


func _on_area_entered(area):
	if area.name == "Player":
		if area.has_method("activate_shield"):
			area.activate_shield()
		var main = get_parent()
		if main.has_method("play_powerup_sound"):
			main.play_powerup_sound()
		queue_free()
