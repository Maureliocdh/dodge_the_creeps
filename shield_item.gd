extends Area2D

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

func _on_area_entered(area):
	# Si el objeto que nos toca es el Player
	if area.name == "Player":
		if area.has_method("activate_shield"):
			area.activate_shield() 
			queue_free()
