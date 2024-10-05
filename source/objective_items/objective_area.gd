extends Area2D

signal objective_area_hit(attacker_player_id: int, is_projectile: bool)


func hit(attacker_player_id: int, is_projectile: bool) -> void:
	objective_area_hit.emit(attacker_player_id, is_projectile)