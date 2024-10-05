extends Node2D


@export var sprites: Array[Sprite2D]


func switch_all_sprite_colors(color_selection: int) -> void:
    for sprite in sprites:
        sprite.switch_sprite_colors(color_selection)