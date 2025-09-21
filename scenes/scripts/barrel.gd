extends AnObject

class_name Barrel

var damage : int = 1

func _ready() -> void:
	super._ready()
	for explosion_sprite in $ExplosionSprites.get_children():
		explosion_sprite.hide()

func die():
	explode()
	super.die()

func explode() -> void:
	# Barrel should explode in a 3x3 area
	var exploded_cells = []
	$HealthComponent.disable()
	for x in range(-1, 2):
		for y in range(-1, 2):
			var cell = current_cell + Vector2i(x, y)
			exploded_cells.append(cell)
	
	for cell in exploded_cells:
		var explosion_sprite = $ExplosionSprites.get_children()[exploded_cells.find(cell)]
		var world_pos_of_cell = GridManager.cell_to_world(cell)
		explosion_sprite.global_position = world_pos_of_cell
		explosion_sprite.show()
		$AnimatedSprite2D.hide()
		explosion_sprite.play("explode")
		
		if GridManager.is_cell_outside_bounds(cell) or cell == current_cell:
			continue
		if not GridManager.is_cell_free(cell):
			var hitEntity = GridManager.get_entity_at_cell(cell)
			var healthComp = hitEntity.get_node_or_null("HealthComponent")
			if healthComp:
				healthComp.take_damage(damage)
