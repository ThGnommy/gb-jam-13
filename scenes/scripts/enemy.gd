class_name Enemy

extends Area2D

@export var animation_speed: float = 1.0
@onready var raycast = $RayCast2D

var moving: bool = false

func _ready() -> void:
	GridManager.add_enemy(self)

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

func take_damage(amount: int) -> void:
	var health = $HealthComponent
	health.take_damage(amount)
