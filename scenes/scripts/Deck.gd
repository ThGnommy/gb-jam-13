extends Node

class_name Deck

var cards : Array[Card] = []

# Already drawn cards
var drawn_cards : Array[Card] = []

func add_card(card: Card) -> void:
	var current_size = cards.size()
	cards.append(card)
	assert(cards.size() == current_size + 1)
	shuffle_deck()

func draw_card() -> Card:
	assert(cards.size() > 0)
	var card = cards.pop_front()
	drawn_cards.append(card)
	return card

func shuffle_deck() -> void:
	cards.shuffle()

# Function to reload the deck with drawn cards and shuffle
func reload_cards() -> void:
	cards += drawn_cards
	drawn_cards.clear()
	shuffle_deck()