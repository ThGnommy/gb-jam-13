class_name PickUp

extends Node2D

var current_cell: Vector2i

@export_enum("Dynamite", "Mortar", "Shotgun", "Lucky", "Beer") var type: String

func pickup():
	return type;

func delete():
	play_sound()
	queue_free()

func play_sound() -> void:
	var stream_player = AudioStreamPlayer.new()
	stream_player.stream = load("res://assets/audio/SFX/Pickup.wav")
	get_parent().add_child(stream_player)
	stream_player.play()
	await stream_player.finished
	stream_player.queue_free()
