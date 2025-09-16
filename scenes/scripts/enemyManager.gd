extends Node2D

@export var enemy_array : Array[Enemy] = []
@export var player : Player

func _ready() -> void:
	player.player_moved.connect(move_enemies)
	pass

func move_enemies() -> void:
	for enemy in enemy_array:
		enemy.do_action(player.position)
