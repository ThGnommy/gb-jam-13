extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()
