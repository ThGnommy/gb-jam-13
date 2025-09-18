class_name Slime
extends Enemy

var current_cell: Vector2i

func _ready() -> void:
	super._ready()
	current_cell = GridManager.world_to_cell(global_position)
	GridManager.occupy_cell(current_cell, GridManager.EntityType.Enemy, self)

func die() -> void:
	GridManager.cleanup_cell(current_cell)
	queue_free()

func do_action(target: Vector2) -> void:
	var dir = _choose_direction(target)
	await GridManager.move_entity(self, GridManager.EntityType.Enemy, Vector2(current_cell.x + dir.x, current_cell.y + dir.y))
	
	#raycast.target_position = dir * TILE_SIZE / 2
	#raycast.force_raycast_update()
#
	#if !raycast.is_colliding():
		#var tween = create_tween()
		#var direction = position + dir * TILE_SIZE
		#tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		#moving = true
		#await tween.finished
		#moving = false
