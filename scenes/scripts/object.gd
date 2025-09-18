extends Area2D

var current_cell: Vector2

func _ready() -> void:
	current_cell = GridManager.world_to_cell(global_position)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Environment, self)

func die():
	GridManager.cleanup_cell(current_cell)
	$AnimatedSprite2D.animation = "destroy"
	await $AnimatedSprite2D.animation_finished
	queue_free()
