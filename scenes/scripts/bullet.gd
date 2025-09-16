extends Node2D

var direction : Vector2 = Vector2.RIGHT

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
	position += direction * 400 * delta
