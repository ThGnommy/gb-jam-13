class_name PickUp

extends Node2D

var current_cell: Vector2i

@export_enum("Dynamite", "Mortar", "Shotgun", "Lucky", "Beer") var type: String



func pickup():
	return type;

func delete():
	queue_free()
