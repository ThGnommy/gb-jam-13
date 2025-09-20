extends DynamiteBullet

var target_distance : float = 0
var target_marker_cell = Vector2i.ZERO
var target_marker_animation : AnimatedSprite2D

func _ready() -> void:
	super._ready()
	damage = 2
	velocity = 150
	range = 4 
	start_cell = GridManager.world_to_cell(global_position)
	target_distance = float(range * GridManager.CELL_SIZE) + float(GridManager.CELL_SIZE * 0.5)
	$FlySprite.z_index = 1

	# Mortar bullet explodes in a 9-cell area (the target cell and the 8 surrounding cells)
	other_cells_modifier = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0),Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

func create_target_marker() -> void:
	## Create an animation 2D node parented to the main tree
	target_marker_animation = AnimatedSprite2D.new()
	target_marker_animation.sprite_frames = preload("res://assets/sprites/Player/mortar_bullet.tres")
	target_marker_animation.animation = "default"
	target_marker_animation.global_position = GridManager.cell_to_world(target_marker_cell)
	target_marker_animation.play("default")

	# Add the target sprite to the main scene tree
	get_tree().get_root().add_child(target_marker_animation)


func fly_animation(px_height: int) -> void:
	var jump_tween = create_tween()

	var animation_duration = (target_distance/ velocity)

	jump_tween.tween_property($FlySprite, "position:y", -px_height, animation_duration/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property($FlySprite, "position:y", 0, animation_duration/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await jump_tween.finished

func verify_hit(cell: Vector2) -> bool:
	# Mortar bullets only explode when they their target cell, regardless of whether it's free or not
	var start_position = GridManager.cell_to_world(start_cell)
	var distance_from_start : float = global_position.distance_to(start_position)
	return distance_from_start >= target_distance - GridManager.CELL_SIZE * 0.5

func set_direction(dir : Vector2) -> void:
	super.set_direction(dir)
	target_marker_cell = start_cell + Vector2i(direction) * range
	create_target_marker()
	fly_animation(20)

func hit_something(cell: Vector2) -> void:
	super.hit_something(cell)
	target_marker_animation.queue_free()
