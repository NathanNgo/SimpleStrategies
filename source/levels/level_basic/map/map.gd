extends Node2D


@export var spawn_point: Node2D


func get_spawn_point() -> Vector2:
	return spawn_point.position