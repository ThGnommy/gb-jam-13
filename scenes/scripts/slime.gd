class_name Slime
extends Enemy

var current_cell: Vector2
@export var manager: Node

func _ready() -> void:
	current_cell = manager.world_to_cell(global_position)
	manager.occupy_cell(current_cell)
	#position = manager.cell_to_world(self.current_cell)
	#manager.occupy_cell(self.current_cell)

func do_action(target: Vector2) -> void:
	var dir = _choose_direction(target)
	await manager.move_enemy(self, current_cell + dir)
	
	#raycast.target_position = dir * TILE_SIZE / 2
	#raycast.force_raycast_update()
#
	#if !raycast.is_colliding():
		#var tween = create_tween()
		#var direction = position + dir * TILE_SIZE
		#tween.tween_property(self, "position", direction, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		#moving = true
		#await tween.finished
		#moving = false
