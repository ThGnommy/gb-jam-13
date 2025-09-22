class_name mortar

extends Enemy

# State 0: loading : do nothing, just wait for the next turn
# State 1: aiming : aim at player and create a target marker if in range
# State 2: waiting : do nothing, just wait for the next turn
# State 3: shooting : shoot at the target marker if it exists
# State 4: waiting : do nothing, just wait for the next turn

var state = 0

var max_range = 6
var min_range = 1
var aiming : Vector2
var target_marker_animation : AnimatedSprite2D

func is_in_range(target):

	var distance = roundi((target - position).length()/ 16)
	print(distance)


	return (distance <= max_range && distance > min_range)

func do_action(target):
	if should_skip_turn():
		_pass_turn()
		return


	if state == 0 && not is_in_range(target):
		print("pass")
		_pass_turn()
		return


	match state:
		0:
			print("Mortar loading")
		1:
			print("Mortar aiming")
		3:
			print("Mortar shooting")
	
	if state == 1:
		aiming = target
		create_target_marker()
		$AcquireTargetAudioStream.play()
	elif state == 3:
		if target_marker_animation:
			var target_marker_position = target_marker_animation.global_position
			var direction = (target_marker_position - position).normalized()
			var target_range = get_target_range()
			BulletFactory.shoot_bullet_at_range("Mortar", position, direction, target_range, self)
			$ShootAudioStream.play()
			destroy_target_marker()
			$AnimatedSprite2D.play("shooting")
		else:
			print("No target marker to shoot at!")
	_pass_turn()

	state+=1 
	state = state %5

func die():
	destroy_target_marker()
	super.die()

func destroy_target_marker():
	if target_marker_animation:
		target_marker_animation.queue_free()

func create_target_marker() -> void:
	if get_target_range() > max_range or get_target_range() <= min_range:
		return
	## Create an animation 2D node parented to the main tree
	target_marker_animation = AnimatedSprite2D.new()
	target_marker_animation.sprite_frames = preload("res://assets/sprites/Player/mortar_bullet.tres")
	target_marker_animation.animation = "default"
	target_marker_animation.global_position = aiming
	target_marker_animation.play("default")

	# Add the target sprite to the main scene tree
	get_tree().get_root().add_child(target_marker_animation)
	$AnimatedSprite2D.play("loading")

func _pass_turn():
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func get_target_range() -> int:
	var target_range : float = abs(position-aiming).length() / float(GridManager.CELL_SIZE)
	return roundi(target_range)

func _on_animated_sprite_2d_animation_finished() -> void:
	if ($AnimatedSprite2D.animation == "shooting"):
		$AnimatedSprite2D.play("idle")


func _on_tree_exited() -> void:
	if target_marker_animation != null:
		target_marker_animation.queue_free()
