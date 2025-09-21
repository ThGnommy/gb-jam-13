extends Control

@onready var main_menu = $MarginContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/ToMainMenu

func _ready() -> void:
	main_menu.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func reset_game_states() -> void:
	GridManager.enemy_array = []
	GridManager.occupancy_map = []
	GridManager.map_matrix_init()
	GridManager.fill_matrix_with_walls()
	TurnManager.current_turn_objects = []
	TurnManager.current_turn = TurnManager.TurnState.Player

func _on_to_main_menu_pressed() -> void:
	reset_game_states()
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
