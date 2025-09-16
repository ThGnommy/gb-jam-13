extends Node2D

func die():
	print("Object destroyed")
	queue_free()
