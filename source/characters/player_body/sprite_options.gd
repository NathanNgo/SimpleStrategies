extends Sprite2D


@export var _sprites: Array[Resource]


func switch_sprite_colors(sprite_selection: int):
    texture = _sprites[sprite_selection]