extends Area2D

signal player_area_hit(attacker_player_id: int)


func hit(attacker_player_id: int) -> void:
	player_area_hit.emit(attacker_player_id)