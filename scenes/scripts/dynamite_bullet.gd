extends Bullet

class_name DynamiteBullet

var other_cells_modifier : Array = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]

func _ready() -> void:
	TurnManager.add_entity_from_current_turn(self)
	velocity = 150
	damage = 2
	range = 2 
	start_cell = GridManager.world_to_cell(global_position)

	# Hide all explosion sprites initially
	for explosionSprite in $ExplosionSprites.get_children():
		explosionSprite.z_index = 1
		explosionSprite.hide()

func _process(delta: float) -> void:
	super._process(delta)

func hit_something(cell: Vector2) -> void:
	$FlySprite.hide()

	var hit_cells = [cell]

	for modifier in other_cells_modifier:
		hit_cells.append(cell + modifier)

	for hit_cell in hit_cells:
		if GridManager.is_cell_outside_bounds(hit_cell):
			continue
		if not GridManager.is_cell_free(hit_cell):
			var hitEntity = GridManager.get_entity_at_cell(hit_cell)
			var healthComp = hitEntity.get_node_or_null("HealthComponent")
			if healthComp:
				healthComp.take_damage(damage)

		var world_pos_of_cell = GridManager.cell_to_world(hit_cell)
		var explosionSprite : AnimatedSprite2D = $ExplosionSprites.get_children()[hit_cells.find(hit_cell)]
		
		# Move the explosion sprite to the correct position and play the animation
		explosionSprite.global_position = world_pos_of_cell
		explosionSprite.show()
		explosionSprite.play("explode")
	
	$AudioStreamPlayer.play()
	var explosion_animation : AnimatedSprite2D = $ExplosionSprites.get_children()[0]
	await explosion_animation.animation_finished
	queue_free()

func _on_tree_exited() -> void:
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
