class_name Slime
extends Enemy

var tilemap_layer: TileMapLayer = null

var pathfinding : AStarGrid2D = AStarGrid2D.new()

@export var damage = 1 

func _ready() -> void:
	tilemap_layer = %WallsLayer 
	super._ready()
	pathfinding.region = tilemap_layer.get_used_rect()
	pathfinding.cell_size = Vector2(16,16)
	pathfinding.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding.update()

	for cell in tilemap_layer.get_used_cells():
		pathfinding.set_point_solid(cell, true)


func do_action(target: Vector2) -> void:
	assert(TurnManager.TurnState.Enemies == TurnManager.current_turn)
	# number of action (max 1 attack)
	for i in 2:
		if _is_in_range(target):
			_attack(target)
		else:
			var path_to_player = pathfinding.get_point_path(position / 16, target / 16)
			if not path_to_player.is_empty():
				path_to_player.remove_at(0)
				await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i( path_to_player[0]/16 ))
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func _attack(target: Vector2):
	$SpritesRoot/AnimatedSprite2D.play("attack")
	var cell = GridManager.world_to_cell(target)
	var hitEntity = GridManager.get_entity_at_cell(cell)
	var healthComp = hitEntity.get_node_or_null("HealthComponent")
	if healthComp:
		healthComp.take_damage(damage)

func _is_in_range(target : Vector2)-> bool:

	var world_target = position + _choose_direction(target) * GridManager.CELL_SIZE
	var target_cell = GridManager.world_to_cell(world_target)

	return target_cell == GridManager.world_to_cell(target)
