extends Node2D

class_name Bullet

signal bullet_destroyed

var direction : Vector2 = Vector2.RIGHT
var last_cell_visited = Vector2.ZERO
var current_cell = Vector2.ZERO
var healthComponentPath = "HealthComponent.tscn"
var should_stop = false
var velocity = 200
var damage = 1
var start_cell = Vector2i.ZERO

# Maximum distance the bullet can travel before exploding
var range = 10

func _ready() -> void:
	start_cell = GridManager.world_to_cell(global_position)
	current_cell = start_cell
	$ExplosionSprite.hide()

func set_direction(dir : Vector2) -> void:
	direction = dir.normalized()
	match(dir):
		Vector2.RIGHT:
			pass
		Vector2.LEFT:
			$FlySprite.flip_h = true
		Vector2.UP:
			$FlySprite.rotation_degrees = -90
		Vector2.DOWN:
			$FlySprite.rotation_degrees = 90

func _process(delta: float) -> void:
	if should_stop:
		return
	position += direction * velocity * delta
	current_cell = GridManager.world_to_cell(position)
	
	if GridManager.is_cell_outside_bounds(current_cell):
		queue_free()
		return

	if(verify_hit(current_cell)):
		should_stop = true
		hit_something(current_cell)

func verify_hit(cell: Vector2) -> bool:
	return !GridManager.is_cell_free(cell) or cell.distance_to(start_cell) >= range 

func hit_something(cell: Vector2) -> void:
	if GridManager.is_cell_free(cell):
		play_hit_animation_and_free()
		return

	var hitEntity = GridManager.get_entity_at_cell(cell)
	var healthComp = hitEntity.get_node_or_null("HealthComponent")
	if healthComp:
		healthComp.take_damage(damage)
	$AudioStreamPlayer.play()
	play_hit_animation_and_free()

func play_hit_animation_and_free() -> void:
	$ExplosionSprite.show()
	$FlySprite.hide()
	$ExplosionSprite.play("explode")
	await $ExplosionSprite.animation_finished
	destroy()

func destroy() -> void:
	bullet_destroyed.emit()
	queue_free()
