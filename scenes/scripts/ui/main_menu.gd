extends Control

@onready var play = $MarginContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/Play

var path_main_scene = "res://scenes/levels/MainScene.tscn"

func _ready() -> void:
	play.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(path_main_scene)
