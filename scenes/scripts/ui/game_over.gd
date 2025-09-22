extends Control

@onready var reload = $MarginContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/Reload

func _ready() -> void:
	reload.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func reset_game_states() -> void:
	GridManager.enemy_array = []
	GridManager.occupancy_map = []
	GridManager.map_matrix_init()
	GridManager.fill_matrix_with_walls()
	TurnManager.current_turn_objects = []
	TurnManager.current_turn = TurnManager.TurnState.Player

func _on_reload_pressed() -> void:
	reset_game_states()
	get_tree().reload_current_scene()
