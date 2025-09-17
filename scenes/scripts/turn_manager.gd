extends Node

enum TurnState {
	Player,
	Enemies,
}

signal turn_change

var current_turn: TurnState = TurnState.Player

func next_turn(turn: TurnState) -> void:
	match turn:
		TurnState.Player:
			current_turn = TurnState.Enemies
		TurnState.Enemies:
			current_turn = TurnState.Player

func get_current_turn() -> TurnState:
	return current_turn
