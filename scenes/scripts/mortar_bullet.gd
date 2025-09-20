extends DynamiteBullet

@export var animation_speed: float = 1.7
var start_cell: Vector2i
var mortar_range: int = 4

func _ready() -> void:
	super._ready()
	damage = 1
	velocity = 100
	$FlySprite.z_index = 1
	start_cell = GridManager.world_to_cell(global_position)

	# Mortar bullet explodes in a 9-cell area (the target cell and the 8 surrounding cells)
	other_cells_modifier = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0),Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

func fly_animation(px_height: int) -> void:
	var jump_tween = create_tween()
	jump_tween.tween_property($FlySprite, "position:y", -px_height, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property($FlySprite, "position:y", 0, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await jump_tween.finished

func verify_hit(cell: Vector2) -> bool:
	# Mortar bullets only explode when they their target cell, regardless of whether it's free or not
	var distance_from_start = cell.distance_to(start_cell)
	return distance_from_start == mortar_range

func set_direction(dir : Vector2) -> void:
	super.set_direction(dir)
	fly_animation(20)
