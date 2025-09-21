extends Node

enum TurnState {
	Player,
	Enemies,
}

var current_turn_objects: Array[Node2D] = []
var current_turn: TurnState = TurnState.Player

func try_update_to_next_turn() -> void:
	if not current_turn_objects.is_empty():
		return

	match current_turn:
		TurnState.Player:
			current_turn = TurnState.Enemies
			GridManager.move_enemies()
		TurnState.Enemies:
			current_turn = TurnState.Player
			current_turn_objects.append(GridManager.player)
			GridManager.player.player_turn()
			

func get_current_turn() -> TurnState:
	return current_turn

func add_entity_from_current_turn(entity: Node2D) -> void:
	current_turn_objects.append(entity)

func add_entities_from_current_turn(entities: Array) -> void:
	current_turn_objects.append(entities)
	
func remove_entity_from_current_turn(entity: Node2D) -> void:
	if current_turn_objects.count(entity) == 0:
		return
	var obj: int = current_turn_objects.find(entity)
	current_turn_objects.remove_at(obj)

func is_turn_of(turn: TurnState) -> bool:
	return current_turn == turn
