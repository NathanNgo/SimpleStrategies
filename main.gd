extends Node2D

@export var goblin_scene: PackedScene
@export var player: CharacterBody2D
@export var world: Node2D
@export var timer: Timer


func _ready():
	player.player_moved.connect(_on_player_moved)
	player.enemies_hit.connect(_on_enemies_hit)
	timer.timeout.connect(_on_timeout)


# func _on_enemies_hit(enemies_hit: Array[CharacterBody2D]):
func _on_enemies_hit(enemies_hit: Array[Node2D]):
	enemies_hit.all(func(enemy): enemy.die())


func _on_player_moved():
	get_tree().call_group("goblins", "move_to", player.position)


func _on_timeout():
	var spawn_position: Vector2 = world.get_spawn_point()
	var goblin: Node2D = goblin_scene.instantiate()
	add_child(goblin)

	goblin.position = spawn_position
	goblin.move_to(player.position)