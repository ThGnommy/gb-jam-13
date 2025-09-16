class_name Enemy

extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D

const TILE_SIZE = 24
var moving: bool = false

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE / 2

func do_action(target:Vector2) -> void:

	print("need to be implemented")
	pass

func _choose_direction(target_position : Vector2) -> Vector2:
	var dir = (target_position - position).normalized()

	if abs(dir.x) > abs(dir.y):
		dir.y = 0
	if abs(dir.x) <= abs(dir.y):
		dir.x = 0
	return dir.normalized()
