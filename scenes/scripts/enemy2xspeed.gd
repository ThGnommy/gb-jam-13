


extends Enemy

#test class to see if we can change behaviour of the enemies

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE / 2

func do_action(target):
	var dir = _choose_direction(target)
	var tween = create_tween()
	var direction = position + dir * TILE_SIZE * 2
	tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	print_debug("move")
	await tween.finished
	moving = false


func die():
	print("Object destroyed")
	queue_free()
