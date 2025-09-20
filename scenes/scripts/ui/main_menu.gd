extends Control

@onready var play = $MarginContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/Play

func _ready() -> void:
	play.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/FabioTest.tscn")
