extends Node2D

enum BulletType {
	Regular,
}

var regular_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/regular_bullet.tscn")
var barrel_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/dynamite_bullet.tscn")
var mortar_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/mortar_bullet.tscn")
var shotgun_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/shotgun_bullet.tscn")

func create_bullet(bullet_type: String) -> Node2D:
	match bullet_type:
		"Regular":
			return regular_bullet_scene.instantiate()
		"Dynamite":
			return barrel_bullet_scene.instantiate()
		"Mortar":
			return mortar_bullet_scene.instantiate()
		"Shotgun":
			return shotgun_bullet_scene.instantiate()
		_:
			return null

func bullet_offset_mult(bullet_type : String) -> float:
	if bullet_type == "Mortar":
		return 0
	else:
		return 1
