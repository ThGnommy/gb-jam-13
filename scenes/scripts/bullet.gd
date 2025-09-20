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

func _ready() -> void:
	TurnManager.add_entity_from_current_turn(self)
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
	
	if(!GridManager.is_cell_free(current_cell)):
		should_stop = true
		hit_something(current_cell)

func hit_something(cell: Vector2) -> void:
	var hitEntity = GridManager.get_entity_at_cell(cell)
	var healthComp = hitEntity.get_node_or_null("HealthComponent")
	if healthComp:
		healthComp.take_damage(damage)
	play_hit_animation_and_free()

func play_hit_animation_and_free() -> void:
	$ExplosionSprite.show()
	$ExplosionSprite.play("explode")
	$FlySprite.hide()
	await $ExplosionSprite.animation_finished
	queue_free()

func _on_tree_exited() -> void:
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
