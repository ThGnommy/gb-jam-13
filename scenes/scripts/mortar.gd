class_name mortar

extends Enemy


# state are:
# 0 -> to load
# 1 -> aiming
# 2 -> shoot
var state = 0

var aiming : Vector2
var target_marker_animation : AnimatedSprite2D

func do_action(target):
	if state == 1:
		aiming = target
		create_target_marker()
		_pass_turn()
	elif state == 3:
		var bullet_instance : Bullet = BulletFactory.create_bullet("Mortar")
		var target_range = (position-aiming).length() / GridManager.CELL_SIZE
		bullet_instance.range = target_range
		var direction = (aiming - position).normalized()
		bullet_instance.position = position + direction * (GridManager.CELL_SIZE * BulletFactory.bullet_offset_mult("Mortar"))
		get_parent().add_child(bullet_instance)
		bullet_instance.set_direction(direction)
		$ShootAudioStream.play()
		bullet_instance.bullet_destroyed.connect(_pass_turn)
		destroy_target_marker()
	else:
		_pass_turn()

	state+=1 
	state = state %5

func destroy_target_marker():
	target_marker_animation.queue_free()

func create_target_marker() -> void:
	## Create an animation 2D node parented to the main tree
	target_marker_animation = AnimatedSprite2D.new()
	target_marker_animation.sprite_frames = preload("res://assets/sprites/Player/mortar_bullet.tres")
	target_marker_animation.animation = "default"
	target_marker_animation.global_position = aiming
	target_marker_animation.play("default")

	# Add the target sprite to the main scene tree
	get_tree().get_root().add_child(target_marker_animation)

func _pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
