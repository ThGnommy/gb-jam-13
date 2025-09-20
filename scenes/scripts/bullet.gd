extends Node2D

class_name Bullet


signal bullet_destroyed

var direction : Vector2 = Vector2.RIGHT
var last_cell_visited = Vector2.ZERO
var current_cell = Vector2.ZERO
var healthComponentPath = "HealthComponent.tscn"
var should_stop = false

func _ready() -> void:
	TurnManager.add_entity_from_current_turn(self)

func set_direction(dir : Vector2) -> void:
	direction = dir.normalized()
	match(dir):
		Vector2.RIGHT:
			pass
		Vector2.LEFT:
			$AnimatedSprite2D.flip_h = true
		Vector2.UP:
			$AnimatedSprite2D.rotation_degrees = -90
		Vector2.DOWN:
			$AnimatedSprite2D.rotation_degrees = 90

func _process(delta: float) -> void:
	if should_stop:
		return
	position += direction * 200 * delta
	current_cell = GridManager.world_to_cell(position)
	
	if GridManager.is_cell_outside_bounds(current_cell):
		queue_free()
		return
	
	if(!GridManager.is_cell_free(current_cell)):
		var hitEntity = GridManager.get_entity_at_cell(current_cell)
		var healthComp = hitEntity.get_node_or_null("HealthComponent")
		if healthComp:
			healthComp.take_damage(1)
		hit_something()

func hit_something() -> void:
	should_stop = true
	$AnimatedSprite2D.play("explode")
	await $AnimatedSprite2D.animation_finished
	queue_free()


func _on_tree_exited() -> void:
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
