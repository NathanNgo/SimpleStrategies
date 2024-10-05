extends Area2D

signal player_area_hit(attacker_player_id: int)


func hit(attacker_player_id: int, _is_projectile: bool) -> void:
	player_area_hit.emit(attacker_player_id)