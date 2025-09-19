class_name Cowboy

extends Enemy

func do_action(target:Vector2) -> void:
	if _is_in_range(target):
		_attack(target)
		return
	var dir = _choose_direction(target)
	await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i( current_cell.x + dir.x, current_cell.y + dir.y))


func _choose_direction(target_position : Vector2) -> Vector2:
	var direction = target_position - position
	if abs(direction.x) < abs(direction.y) :
		return Vector2(direction.x, 0).normalized()
	return Vector2(0, direction.y).normalized()

func _is_in_range(target : Vector2):

	var target_cell = GridManager.world_to_cell(target)

	return target_cell.x == current_cell.x || target_cell.y == current_cell.y


func _attack(target: Vector2):
	var dir = (target - position).normalized()
	# Create and shoot the bullet
	var bullet_instance = BulletFactory.create_bullet("Regular")
	bullet_instance.position = position + dir * GridManager.CELL_SIZE
	bullet_instance.set_direction(dir)
	get_parent().add_child(bullet_instance)
	print("Cowboy attack: ", target)
