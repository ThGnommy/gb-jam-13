extends Node2D

enum EntityType {
	Unknown,
	Player,
	Enemy,
	Projectile,
	Environment
}

@export var enemy_array : Array[Enemy] = []
@export var grid_size = Vector2i(10, 10)
var player : Player

var CellData := {
	"occupied": false,
	"entity": EntityType.Unknown
}

const CELL_SIZE = 24
var occupancy_map : Array = []

func _init() -> void:
	map_matrix_init()

func set_player(p: Player) -> void:
	player = p

func add_enemy(enemy: Enemy) -> void:
	enemy_array.append(enemy)

func move_enemies() -> void:
	for enemy in enemy_array:
		enemy.do_action(player.position)

func map_matrix_init():
	occupancy_map.resize(grid_size.x)
	for x in range(grid_size.x):
		occupancy_map[x] = []
		occupancy_map[x].resize(grid_size.y)
		for y in range(grid_size.y):
			var data: Dictionary
			data["occupied"] = false
			data["entity"] = EntityType.Unknown
			occupancy_map[x][y] = data

func is_cell_free(cell: Vector2i) -> bool:
	return not occupancy_map[cell.x][cell.y]["occupied"]

func occupy_cell(cell: Vector2i, entity: EntityType):
	occupancy_map[cell.x][cell.y]["occupied"] = true
	occupancy_map[cell.x][cell.y]["entity"] = entity
	
func free_cell(cell: Vector2i):
	occupancy_map[cell.x][cell.y]["occupied"] = false
	occupancy_map[cell.x][cell.y]["entity"] = EntityType.Unknown

func move_entity(entity: Node2D, entity_type: EntityType, target_cell: Vector2i, animation_speed: float = 4.0) -> bool:
	# Out-of-bounds check
	if target_cell.x < 0 or target_cell.y < 0 or target_cell.x >= grid_size.x or target_cell.y >= grid_size.y:
		return false
	# Check if the target cell is free
	if is_cell_free(target_cell):
		# Reserve the cell immediately so no other enemy moves into it
		occupy_cell(target_cell, entity_type)
		var start_pos: Vector2 = entity.global_position
		var target_pos: Vector2 = cell_to_world(target_cell)
		# Create tween
		var tween = entity.create_tween()
		tween.tween_property(entity, "global_position", target_pos, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		# Wait until the tween finishes
		await tween.finished
		# Update occupancy: free old cell after movement
		free_cell(entity.current_cell)
		entity.current_cell = target_cell
		return true
	return false

func cell_to_world(cell: Vector2i) -> Vector2i:
	return Vector2i(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func world_to_cell(pos: Vector2i) -> Vector2i:
	return Vector2i(pos.x / CELL_SIZE, pos.y / CELL_SIZE)

func _draw():
	for x in range(grid_size.x):
		var start = Vector2i(x * CELL_SIZE, 0)
		var end = Vector2i(x * CELL_SIZE, grid_size.y * CELL_SIZE)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)

	for y in range(grid_size.y):
		var start = Vector2i(0, y * CELL_SIZE)
		var end = Vector2i(grid_size.x * CELL_SIZE, y * CELL_SIZE)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)
