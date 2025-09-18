extends Bullet

func _process(delta: float) -> void:
	$AnimatedSprite2D.rotation_degrees += 20
	super._process(delta)
