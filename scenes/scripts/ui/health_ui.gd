extends Control

@export var player: Player

func _ready() -> void:
	player.player_health_change.connect(_on_health_change)
	player.get_node_or_null("HealthComponent")
	$Container/AnimatedSprite2D.animation = "5"

func _on_health_change(value):
	$Container/AnimatedSprite2D.animation = str(value)
