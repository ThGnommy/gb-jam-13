extends Node2D

@export var enemy_array : Array[Enemy] = []
@export var player : Player
@export var grid_size = Vector2i(10, 10)

var cell_size = 24
@export var occupancy_map : Array = []

func _init() -> void:
	map_matrix_init()

func _ready() -> void:
	player.player_moved.connect(move_enemies)

func move_enemies() -> void:
	for enemy in enemy_array:
		enemy.do_action(player.position)

func map_matrix_init():
	occupancy_map.resize(grid_size.x)
	for x in range(grid_size.x):
		occupancy_map[x] = []
		occupancy_map[x].resize(grid_size.y)
		for y in range(grid_size.y):
			occupancy_map[x][y] = false

func is_cell_free(cell: Vector2i) -> bool:
	return not occupancy_map[cell.x][cell.y]
	
func occupy_cell(cell: Vector2i):
	occupancy_map[cell.x][cell.y] = true
	
func free_cell(cell: Vector2i):
	occupancy_map[cell.x][cell.y] = false
	
func move_enemy(enemy, target_cell: Vector2i, animation_speed: float = 4.0) -> bool:
	# Out-of-bounds check
	if target_cell.x < 0 or target_cell.y < 0 or target_cell.x >= grid_size.x or target_cell.y >= grid_size.y:
		return false
	# Check if the target cell is free
	if is_cell_free(target_cell):
		# Reserve the cell immediately so no other enemy moves into it
		occupy_cell(target_cell)
		var start_pos: Vector2 = enemy.global_position
		var target_pos: Vector2 = cell_to_world(target_cell)
		# Create tween
		var tween = enemy.create_tween()
		tween.tween_property(enemy, "global_position", target_pos, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		# Wait until the tween finishes
		await tween.finished
		# Update occupancy: free old cell after movement
		free_cell(enemy.current_cell)
		enemy.current_cell = target_cell
		return true
	return false

func cell_to_world(cell: Vector2i) -> Vector2i:
	return Vector2i(cell.x * cell_size, cell.y * cell_size)

func world_to_cell(pos: Vector2i) -> Vector2i:
	return Vector2i(pos.x / cell_size, pos.y / cell_size)

func _draw():
	for x in range(grid_size.x):
		var start = Vector2i(x * cell_size, 0)
		var end = Vector2i(x * cell_size, grid_size.y * cell_size)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)

	for y in range(grid_size.y):
		var start = Vector2i(0, y * cell_size)
		var end = Vector2i(grid_size.x * cell_size, y * cell_size)
		draw_line(start, end, Color.DARK_GOLDENROD, 1.0)
