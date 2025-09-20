extends DynamiteBullet


func _ready() -> void:
	super._ready()
	damage = 1
	velocity = 100
	
	# Mortar bullet explodes in a 9-cell area (the target cell and the 8 surrounding cells)
	other_cells_modifier = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0),Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
