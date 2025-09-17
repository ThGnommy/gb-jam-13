extends Enemy

#test class to see if we can change behaviour of the enemies

func do_action(target):
	# this method can be used to customie the behaviour of the enemies, it can attack/move/prepare/wait in response to the player position
	var dir = _choose_direction(target)
	var tween = create_tween()

	# here we move twice in the same direction
	var direction = position + dir * TILE_SIZE * 2
	tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	print_debug("move")
	await tween.finished
	moving = false
