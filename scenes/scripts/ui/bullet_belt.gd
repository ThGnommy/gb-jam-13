extends Control

@export var player: Player
@onready var ui_belt = $Belt

var bullet_map: Dictionary = {
	"Regular": "res://assets/sprites/Player/ShotgunBullet.png",
	"Dynamite": "res://assets/sprites/Player/DynamiteBullet.png",
	"Mortar": "res://assets/sprites/Player/MortarBullet.png",
	"Shotgun": "res://assets/sprites/Player/ShotgunBullet.png"
}

func _ready() -> void:
	update_belt()

func update_belt() -> void:
	var bullet_belt = player.belt
	
	for i in ui_belt.get_children().size():
		var rect: TextureRect = ui_belt.get_child(i)
		rect.texture = load(bullet_map[bullet_belt[i]])

func _on_player_belt_changed(value: Variant) -> void:
	update_belt()
