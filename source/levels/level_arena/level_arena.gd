extends Node2D

@export var _player: CharacterBody2D


func _ready() -> void:
	_player.enemies_hit.connect(_on_enemies_hit)


func _on_enemies_hit(enemies_hit: Array[Node2D]) -> void:
	for enemy in enemies_hit:
		enemy.die()