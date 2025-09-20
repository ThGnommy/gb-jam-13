extends Control


func _process(delta: float) -> void:
	$CanvasLayer/Label.text = str(TurnManager.get_current_turn())
