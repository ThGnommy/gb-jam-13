class_name Slime
extends Enemy

var tilemap_layer: TileMapLayer = null

var pathfinding : AStarGrid2D = AStarGrid2D.new()

@export var damage = 1 
@onready var anim = $SpritesRoot/AnimatedSprite2D

func _ready() -> void:
	tilemap_layer = %WallsLayer 
	super._ready()
	pathfinding.region = tilemap_layer.get_used_rect()
	pathfinding.cell_size = Vector2(16,16)
	pathfinding.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinding.update()

	for cell in tilemap_layer.get_used_cells():
		pathfinding.set_point_solid(cell, true)


var cache_obstacles : Array[Vector2i]

func add_obstacles(obstacles : Array[Vector2i]):

	cache_obstacles.clear()
	cache_obstacles = obstacles
	for obst in obstacles:
		pathfinding.set_point_solid(obst, true)


func do_action(target: Vector2) -> void:
	print(is_active)
	if should_skip_turn():
		pass_turn()
		return
	assert(TurnManager.TurnState.Enemies == TurnManager.current_turn)
	# number of action (max 1 attack)
	for i in 2:
		if _is_in_range(target):
			var dir = Vector2i(_choose_direction(target))
			match dir:
				Vector2i.RIGHT:
					anim.flip_h = false
					anim.play("Attack")
					await anim.animation_finished
				Vector2i.UP:
					anim.play("AttackUp")
					await anim.animation_finished
				Vector2i.LEFT:
					print("attack", dir)
					anim.flip_h = true
					anim.play("Attack")
					await anim.animation_finished
				Vector2i.DOWN:
					anim.play("AttackDown")
					await anim.animation_finished
					
			_attack(target)
			pass_turn()
			return
			# anim.play("idle")
		else:
			var path_to_player = pathfinding.get_point_path(position / 16, target / 16)
			if not path_to_player.is_empty():
				path_to_player.remove_at(0)
				jump_animation(10)
				await GridManager.move_entity(self, GridManager.EntityType.Enemy,Vector2i(path_to_player[0]/16))
		pass_turn()

func jump_animation(px_height: int) -> void:
	var jump_tween = create_tween()
	$SpritesRoot/AnimatedSprite2D.animation = "jump"
	jump_tween.tween_property(anim, "position:y", -px_height, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(anim, "position:y", 0, 1.0 / animation_speed / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	jump_tween.tween_callback(play_idle_anim)

func play_idle_anim() -> void:
	$SpritesRoot/AnimatedSprite2D.animation = "idle"

func pass_turn():
	for obst in cache_obstacles:
		pathfinding.set_point_solid(obst, false)
	TurnManager.remove_entity_from_current_turn(self)
	TurnManager.try_update_to_next_turn()

func _attack(target: Vector2):
	$SpritesRoot/AnimatedSprite2D.play("attack")
	$SlimeAttack.play()
	var cell = GridManager.world_to_cell(target)
	var hitEntity = GridManager.get_entity_at_cell(cell)
	var healthComp = hitEntity.get_node_or_null("HealthComponent")
	if healthComp:
		healthComp.take_damage(damage)

func _is_in_range(target : Vector2)-> bool:

	var world_target = position + _choose_direction(target) * GridManager.CELL_SIZE
	var target_cell = GridManager.world_to_cell(world_target)

	return target_cell == GridManager.world_to_cell(target)


func _on_animated_sprite_2d_animation_finished() -> void:
	if (anim.animation != "idle"):
		anim.play("idle")
