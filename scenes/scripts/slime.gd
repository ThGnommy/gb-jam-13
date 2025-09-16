class_name Slime

extends Enemy

func do_action(target:Vector2) -> void:
	var dir = _choose_direction(target)

	raycast.target_position = dir * TILE_SIZE / 2
	raycast.force_raycast_update()
	if !raycast.is_colliding():
		var tween = create_tween()
		var direction = position + dir * TILE_SIZE
		tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		print_debug("move")
		await tween.finished
		moving = false
