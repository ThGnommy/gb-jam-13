class_name mortar

extends Enemy


# state are:
# 0 -> to load
# 1 -> aiming
# 2 -> shoot
var state = 0

@onready var Bullet = preload("res://scenes/bullet.tscn")

func do_action(target):
	
	if state == 0:
		pass
	elif state == 1:
		# highlight the target cell
		pass
	elif state == 2:
		# shoot at position
		var bullet_instance = Bullet.instantiate()
		bullet_instance.position = position
		get_parent().add_child(bullet_instance)
		var tween = create_tween()
		tween.tween_property(self, "position", target, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		await tween.finished

		# emit damage in target
		#
		return

	state+=1 
	state = state %3
