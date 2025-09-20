extends Control

@onready var reload = $MarginContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/Reload

func _ready() -> void:
	reload.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()
