class_name Enemy

extends Area2D

@export var animation_speed: float = 1.0
var current_cell: Vector2i

@onready var raycast = $RayCast2D

var moving: bool = false

func _ready() -> void:
	GridManager.add_enemy(self)
	current_cell = GridManager.world_to_cell(global_position)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Enemy, self)

func do_action(target:Vector2) -> void:
	print("need to be implemented")

func _choose_direction(target_position : Vector2) -> Vector2:
	var dir = (target_position - position).normalized()

	if abs(dir.x) > abs(dir.y):
		dir.y = 0
	if abs(dir.x) <= abs(dir.y):
		dir.x = 0
	return dir.normalized()

func take_damage(amount: int) -> void:
	var health = $HealthComponent
	health.take_damage(amount)

func _attack(target: Vector2):
	print("need to be implemented")

func _is_in_range(target : Vector2) ->bool:
	print("need to be implemented")
	return false

func die() -> void:
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
	GridManager.cleanup_cell(current_cell)
	queue_free()
