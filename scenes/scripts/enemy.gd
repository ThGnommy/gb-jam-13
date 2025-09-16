class_name Enemy

extends Area2D

@export var animation_speed = 1
@onready var raycast = $RayCast2D

const TILE_SIZE = 24
var moving: bool = false

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE / 2

func move(target:Vector2) -> void:
	var dir = (target - position).normalized()

	if abs(dir.x) > abs(dir.y):
		dir.y = 0
	if abs(dir.x) <= abs(dir.y):
		dir.x = 0
	dir = dir.normalized()

	raycast.target_position = dir * TILE_SIZE / 2
	raycast.force_raycast_update()
	if !raycast.is_colliding():
		var tween = create_tween()
		var direction = position + dir * TILE_SIZE
		tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		print_debug("move")
		await tween.finished
		moving = false
