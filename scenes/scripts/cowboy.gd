class_name Cowboy

extends Enemy



func _ready() -> void:
	super._ready()

func do_action(target:Vector2) -> void:
	if should_skip_turn():
		pass_turn()
		return

	assert(TurnManager.TurnState.Enemies == TurnManager.current_turn)
	if _is_in_range(target):
		_attack(target)
		return

	var dir = _choose_direction(target)
	$JumpAudioStream.play()
	await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i( current_cell.x + dir.x, current_cell.y + dir.y))
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func _choose_direction(target_position : Vector2) -> Vector2:
	var direction = target_position - position
	if abs(direction.x) < abs(direction.y) :
		return Vector2(direction.x, 0).normalized()
	return Vector2(0, direction.y).normalized()

func _is_in_range(target: Vector2):
	var target_cell = GridManager.world_to_cell(target)
	return target_cell.x == current_cell.x || target_cell.y == current_cell.y

func _attack(target: Vector2):
	var dir = (target - position).normalized()
	# Create and shoot the bullet
	var bullet_instance :Bullet = BulletFactory.create_bullet("Regular")
	bullet_instance.position = position + dir * GridManager.CELL_SIZE
	bullet_instance.set_direction(dir)
	get_parent().add_child(bullet_instance)
	$ShootAudioStream.play()
	bullet_instance.bullet_destroyed.connect(pass_turn)

func pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
