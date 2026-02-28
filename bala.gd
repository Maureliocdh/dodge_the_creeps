extends Area2D
@export var speed = 400
var direction = Vector2.UP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# La bala siempre se mueve hacia arriba (o cambia a Vector2.RIGHT si prefieres)
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.queue_free() # Mata al enemigo 
		queue_free() # Se destruye la bala


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
		queue_free()
