extends Bullet

func _ready() -> void:
	TurnManager.add_entity_from_current_turn(self)

func _process(delta: float) -> void:
	$AnimatedSprite2D.rotation_degrees += 20
	super._process(delta)

func _on_tree_exited() -> void:
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()
