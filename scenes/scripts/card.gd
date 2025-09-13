extends Node

class_name Card
var card_name : String = ""
var description : String = ""
var sprite : AnimatedSprite2D

# Damage associated with the card, could be used to differentiate between types
var damage : int = 0

# value required for being pulled from the card pool
var rng_required : float = 0.0
