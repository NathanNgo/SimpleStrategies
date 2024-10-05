extends Node


var registry = {}


func add_player(player_id: int, player: Node2D) -> void:
	registry[player_id] = player


func get_player(player_id: int) -> Node2D:
	return registry[player_id]


func get_all_players() -> Variant:
	return registry