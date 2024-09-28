extends Area2D

signal player_area_hit


func hit():
	player_area_hit.emit()