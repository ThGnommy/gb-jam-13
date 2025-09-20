class_name mortar

extends Enemy


# state are:
# 0 -> to load
# 1 -> aiming
# 2 -> shoot
var state = 0

var aiming : Vector2i

func do_action(target):
	if state == 0:
		aiming = GridManager.world_to_cell(target)
	elif state == 3:
		var bullet_instance : Bullet = BulletFactory.create_bullet("Mortar")
		bullet_instance.position = position * (GridManager.CELL_SIZE * BulletFactory.bullet_offset_mult("Mortar"))
		get_parent().add_child(bullet_instance)
		bullet_instance.set_direction(target)
		$ShootAudioStream.play()
		bullet_instance.bullet_destroyed.connect(_pass_turn)

		return

	state+=1 
	state = state %5

func _pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
