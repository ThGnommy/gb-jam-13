extends Node2D

var regular_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/regular_bullet.tscn")
var barrel_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/dynamite_bullet.tscn")
var mortar_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/mortar_bullet.tscn")
var shotgun_bullet_scene: PackedScene = preload("res://scenes/objects/bullets/shotgun_bullet.tscn")

var barrel_bullet_pickup_scene: PackedScene = preload("res://scenes/objects/pickups/dynamite-pickup.tscn")
var mortar_bullet_pickup_scene: PackedScene = preload("res://scenes/objects/pickups/mortar-pickup.tscn")
var shotgun_bullet_pickup_scene: PackedScene = preload("res://scenes/objects/pickups/shotgun-pickup.tscn")

var not_spawned_pickups: Array = ["Dynamite", "Mortar", "Shotgun"]

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

func create_bullet_pickup(bullet_type: String) -> Node2D:
	match bullet_type:
		"Dynamite":
			return barrel_bullet_pickup_scene.instantiate()
		"Mortar":
			return mortar_bullet_pickup_scene.instantiate()
		"Shotgun":
			return shotgun_bullet_pickup_scene.instantiate()
		_:
			return null

func shoot_bullet(bullet_type: String, shooter_position: Vector2, shooter_direction: Vector2, shooter) -> void:
	var bullet_instance : Bullet = create_bullet(bullet_type)
	bullet_instance.global_position = shooter_position + shooter_direction * (GridManager.CELL_SIZE * bullet_offset_mult(bullet_type))
	bullet_instance.bullet_destroyed.connect(shooter._pass_turn)
	shooter.get_parent().add_child(bullet_instance)
	bullet_instance.set_direction(shooter_direction)

func shoot_bullet_at_range(bullet_type: String, shooter_position: Vector2, shooter_direction: Vector2, range: int, shooter) -> void:
	var bullet_instance : Bullet = create_bullet(bullet_type)
	if (bullet_instance.has_method("disableMarker")):
		bullet_instance.disableMarker()
	bullet_instance.global_position = shooter_position + shooter_direction * (GridManager.CELL_SIZE * bullet_offset_mult(bullet_type))
	bullet_instance.bullet_destroyed.connect(shooter._pass_turn)
	shooter.get_parent().add_child(bullet_instance)
	bullet_instance.range = range
	bullet_instance.set_direction(shooter_direction)
