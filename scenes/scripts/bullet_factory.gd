extends Node2D

enum BulletType {
	Regular,
}

var regular_bullet_scene: PackedScene = preload("res://scenes/regular_bullet.tscn")
var barrel_bullet_scene: PackedScene = preload("res://scenes/dynamite_bullet.tscn")
var mortar_bullet_scene: PackedScene = preload("res://scenes/mortar_bullet.tscn")

func create_bullet(bullet_type: String) -> Node2D:
	match bullet_type:
		"Regular":
			return regular_bullet_scene.instantiate()
		"Dynamite":
			return barrel_bullet_scene.instantiate()
		"Mortar":
			return mortar_bullet_scene.instantiate()
		_:
			return null
