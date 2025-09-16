extends Area2D

const TILE_SIZE = 24

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE / 2

func die():
	print("Object destroyed")
	queue_free()
