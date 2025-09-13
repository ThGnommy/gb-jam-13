extends Node

class_name CardPool

var cards : Array[Card] = []

func _ready():
	# Initialize the card pool with some cards
	create_card("Paper Card", "A simple paper card.", AnimatedSprite2D.new(), 1, 0.0)
	create_card("Rock Card", "A sturdy rock card.", AnimatedSprite2D.new(), 2, 0.0)
	create_card("Scissors Card", "A sharp scissors card.", AnimatedSprite2D.new(), 3, 0.0)


func create_card(card_name: String, description: String, sprite: AnimatedSprite2D, damage: int, rng_required: float) -> Card:
	var new_card = Card.new()
	new_card.card_name = card_name
	new_card.description = description
	new_card.sprite = sprite
	new_card.damage = damage
	new_card.rng_required = rng_required
	cards.append(new_card)
	return new_card

func pick_random_card(roll : float) -> Card:
	var possible_cards = cards.filter(func(card): return roll >= card.rng_required)
	
	# Since there are cards with 0 required roll, this function should always find a card
	assert(possible_cards.size() > 0)

	possible_cards.shuffle()
	return possible_cards[0]
