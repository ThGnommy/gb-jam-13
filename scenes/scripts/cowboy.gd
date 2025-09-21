class_name Cowboy

extends Enemy

@onready var anim = $SpritesRoot/AnimatedSprite2D

func _ready() -> void:
	super._ready()

func do_action(target:Vector2) -> void:
	assert(TurnManager.TurnState.Enemies == TurnManager.current_turn)
	if _is_in_range(target):
		_attack(target)
		return
	
	var dir = _choose_direction(target)
	$JumpAudioStream.play()
	animate(dir)
	await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i( current_cell.x + dir.x, current_cell.y + dir.y))
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func _choose_direction(target_position : Vector2) -> Vector2:
	var direction = target_position - position
	if abs(direction.x) < abs(direction.y) :
		return Vector2(direction.x, 0).normalized()
	return Vector2(0, direction.y).normalized()

func _is_in_range(target: Vector2):
	var target_cell = GridManager.world_to_cell(target)
	return target_cell.x == current_cell.x || target_cell.y == current_cell.y

func _attack(target: Vector2):
	var dir = (target - position).normalized()
	
	match dir:
		Vector2.RIGHT:
			anim.flip_h = false
			anim.play("shoot_right")
			await anim.animation_finished
			anim.play("idle")
		Vector2.UP:
			anim.play("shoot_up")
			await anim.animation_finished
			anim.play("idle_up")
		Vector2.LEFT:
			anim.flip_h = true
			anim.play("shoot_right")
			await anim.animation_finished
			anim.play("idle")
		Vector2.DOWN:
			anim.play("shoot_down")
			await anim.animation_finished
			anim.play("idle_down")
	
	# Create and shoot the bullet
	var bullet_instance :Bullet = BulletFactory.create_bullet("Regular")
	bullet_instance.position = position + dir * GridManager.CELL_SIZE
	bullet_instance.set_direction(dir)
	get_parent().add_child(bullet_instance)
	$ShootAudioStream.play()
	bullet_instance.bullet_destroyed.connect(pass_turn)

func jump_animation(px_height: int) -> void:
	var jump_tween = create_tween()
	$SpritesRoot/AnimatedSprite2D.animation = "jump"
	jump_tween.tween_property(anim, "position:y", -px_height, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	jump_tween.tween_callback(play_idle_anim)

func play_idle_anim() -> void:
	$SpritesRoot/AnimatedSprite2D.animation = "idle"

func animate(dir) -> void:
	match dir:
		Vector2.RIGHT:
			jump_animation(10)
			anim.play("jump_side")
			anim.flip_h = false
			await anim.animation_finished
			anim.play("idle")
		Vector2.LEFT:
			jump_animation(10)
			anim.play("jump_side")
			anim.flip_h = true
			await anim.animation_finished
			anim.play("idle")
		Vector2.UP:
			jump_animation(5)
			anim.play("jump_top")
			await anim.animation_finished
			anim.play("idle_up")
		Vector2.DOWN:
			jump_animation(5)
			anim.play("jump_down")
			await anim.animation_finished
			anim.play("idle_down")

func pass_turn():
	print("Cowboy pass turn")
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
