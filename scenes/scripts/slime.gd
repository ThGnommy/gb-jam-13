class_name Slime
extends Enemy

func _ready() -> void:
	super._ready()

func die() -> void:
	GridManager.cleanup_cell(current_cell)
	queue_free()

func do_action(target: Vector2) -> void:

	# number of action (max 1 attack)
	for i in 2:
		if _is_in_range(target):
			_attack(target)
			return
		var dir = _choose_direction(target)
		print(dir)
		await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i( current_cell.x + dir.x, current_cell.y + dir.y))

func _attack(target: Vector2):
	print("attack on: ", target)

func _is_in_range(target : Vector2)-> bool:

	var world_target = position + _choose_direction(target) * GridManager.CELL_SIZE
	var target_cell = GridManager.world_to_cell(world_target)

	return target_cell == GridManager.world_to_cell(target)
