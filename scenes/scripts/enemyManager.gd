extends Node2D

enum EntityType {
	Unknown,
	Player,
	Enemy,
	Projectile,
	Environment,
	Pickup
}

@export var enemy_array : Array[Enemy] = []
@export var grid_size = Vector2i(128, 128)
@export var tilemap_walls: TileMapLayer
var player : Player

var CellData := {
	"occupied": false,
	"entityType": EntityType.Unknown,
	"entity" : Node2D
}

const CELL_SIZE : int = 16
var occupancy_map : Array = []

func _init() -> void:
	map_matrix_init()
	
func _ready() -> void:
	fill_matrix_with_walls()

func set_player(p: Player) -> void:
	player = p

func add_enemy(enemy: Enemy) -> void:
	enemy_array.append(enemy)

func move_enemies() -> void:
	if enemy_array.is_empty():
		TurnManager.try_update_to_next_turn()
		return
	for enemy in enemy_array:
		TurnManager.add_entity_from_current_turn(enemy)
	for enemy in enemy_array:
		if enemy.has_method("add_obstacles"):
			var obstacles : Array[Vector2i]
			for row in occupancy_map.size():
				for col in occupancy_map[0].size():
					var entityType = occupancy_map[row][col]["entityType"]
					if entityType == EntityType.Environment || entityType == EntityType.Enemy:
						obstacles.append(Vector2i(row,col))
					
			enemy.add_obstacles(obstacles)
		enemy.do_action(player.position)

func map_matrix_init():
	occupancy_map.resize(grid_size.x)
	for x in range(grid_size.x):
		occupancy_map[x] = []
		occupancy_map[x].resize(grid_size.y)
		for y in range(grid_size.y):
			var data: Dictionary
			data["occupied"] = false
			data["entityType"] = EntityType.Unknown
			data["entity"] = null
			occupancy_map[x][y] = data

func is_cell_free(cell: Vector2i) -> bool:
	assert(is_cell_outside_bounds(cell) == false)
	return not occupancy_map[cell.x][cell.y]["occupied"]

func is_cell_outside_bounds(cell: Vector2i) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x >= grid_size.x or cell.y >= grid_size.y

func get_entity_at_cell(cell: Vector2i) -> Node2D:
	assert(cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y)
	assert(occupancy_map[cell.x][cell.y]["occupied"])
	return occupancy_map[cell.x][cell.y]["entity"]

func occupy_cell(cell: Vector2i, entityType: EntityType, entity: Node2D):
	occupancy_map[cell.x][cell.y]["occupied"] = true
	occupancy_map[cell.x][cell.y]["entityType"] = entityType
	occupancy_map[cell.x][cell.y]["entity"] = entity

func free_cell(cell: Vector2i):
	occupancy_map[cell.x][cell.y]["occupied"] = false
	occupancy_map[cell.x][cell.y]["entityType"] = EntityType.Unknown
	occupancy_map[cell.x][cell.y]["entity"] = null

func cleanup_cell(cell: Vector2i):
	# Cleanup enemy array if an enemy is being removed	
	if(occupancy_map[cell.x][cell.y]["entityType"] == EntityType.Enemy):
		for enemy in enemy_array:
			if enemy.current_cell == cell:
				enemy_array.erase(enemy)
				break
	
	free_cell(cell)

func move_entity(entity: Node2D, entity_type: EntityType, target_cell: Vector2i) -> bool:
	# Out-of-bounds check
	if target_cell.x < 0 or target_cell.y < 0 or target_cell.x >= grid_size.x or target_cell.y >= grid_size.y:
		return false
	# Check if the target cell is free
	if is_cell_free(target_cell):
		free_cell(entity.current_cell)
		occupy_cell(target_cell, entity_type, entity)
		entity.current_cell = target_cell
		
		var start_pos: Vector2 = entity.global_position
		var target_pos: Vector2 = cell_to_world(target_cell)

		var tween = entity.create_tween()
		tween.tween_property(entity, "global_position", target_pos, 1.0 / entity.animation_speed).set_trans(Tween.TRANS_SINE)

		await tween.finished
		return true
	return false

func cell_to_world(cell: Vector2i) -> Vector2i:
	return Vector2i(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(roundi(pos.x / CELL_SIZE), roundi(pos.y / CELL_SIZE))

func fill_matrix_with_walls():
	
	if tilemap_walls:
		var used_cells = tilemap_walls.get_used_cells()
		
		for cell in used_cells:
			GridManager.occupy_cell(cell, GridManager.EntityType.Environment, Node2D.new())

####### debug grid ######
func _draw():
	var half_cell : float = float(CELL_SIZE) * 0.5
	for x in range(grid_size.x):
		var start = Vector2(x * CELL_SIZE - half_cell, 0)
		var end = Vector2(x * CELL_SIZE - half_cell, grid_size.y * CELL_SIZE)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)

	for y in range(grid_size.y):
		var start = Vector2(0, y * CELL_SIZE - half_cell)
		var end = Vector2(grid_size.x * CELL_SIZE - half_cell, y * CELL_SIZE - half_cell)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)
