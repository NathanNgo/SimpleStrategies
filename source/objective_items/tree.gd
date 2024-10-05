extends Node2D


@export var _tree_sprites: AnimatedSprite2D


func _process(_delta: float) -> void:
	_tree_sprites.play("idle")