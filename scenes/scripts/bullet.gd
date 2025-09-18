extends Node2D

var direction : Vector2 = Vector2.RIGHT
var last_cell_visited = Vector2.ZERO
var current_cell = Vector2.ZERO

func set_direction(dir : Vector2) -> void:
	direction = dir.normalized()
	match(dir):
		Vector2.RIGHT:
			pass
		Vector2.LEFT:
			$AnimatedSprite2D.flip_h = true
		Vector2.UP:
			$AnimatedSprite2D.rotation_degrees = -90
		Vector2.DOWN:
			$AnimatedSprite2D.rotation_degrees = 90

func _process(delta: float) -> void:
	position += direction * 200 * delta
	current_cell = GridManager.world_to_cell(position)
	if(!GridManager.is_cell_free(current_cell)):
		print("Hit")
		queue_free()
