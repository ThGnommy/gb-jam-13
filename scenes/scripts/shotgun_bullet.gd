extends Bullet

var affected_cells : Array = []

func _ready() -> void:
	super._ready()
	damage = 10
	range = 0

func set_direction(dir : Vector2) -> void:
	direction = dir.normalized()
	match(dir):
		Vector2.RIGHT:
			affected_cells = [Vector2i.ZERO, Vector2i.ZERO + Vector2i.RIGHT, Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]
		Vector2.LEFT:
			$ExplosionSprite.flip_h = true
			affected_cells = [Vector2i.ZERO, Vector2i.ZERO + Vector2i.LEFT, Vector2i.LEFT + Vector2i.UP, Vector2i.LEFT + Vector2i.DOWN]
		Vector2.UP:
			$ExplosionSprite.rotation_degrees = -90
			affected_cells = [Vector2i.ZERO, Vector2i.ZERO + Vector2i.UP, Vector2i.UP + Vector2i.RIGHT, Vector2i.UP + Vector2i.LEFT]
		Vector2.DOWN:
			$ExplosionSprite.rotation_degrees = 90
			affected_cells = [Vector2i.ZERO, Vector2i.ZERO + Vector2i.DOWN, Vector2i.DOWN + Vector2i.RIGHT, Vector2i.DOWN + Vector2i.LEFT]

	$FlySprite.hide()
	for affected_cell in affected_cells:
		var hit_cell = current_cell + affected_cell
		print("hit cell is, ", hit_cell)
		if GridManager.is_cell_outside_bounds(hit_cell):
			continue
		if not GridManager.is_cell_free(hit_cell):
			var hitEntity = GridManager.get_entity_at_cell(hit_cell)
			var healthComp = hitEntity.get_node_or_null("HealthComponent")
			if healthComp:
				healthComp.take_damage(damage)
	play_hit_animation_and_free()
