extends Node2D

@export var _goblin_scene: PackedScene
@export var _player: CharacterBody2D
@export var _spawn_point: Node2D
@export var _timer: Timer


func _ready() -> void:
	_player.player_moved.connect(_on_player_moved)
	_player.enemies_hit.connect(_on_enemies_hit)
	_timer.timeout.connect(_on_timeout)


func _on_enemies_hit(enemies_hit: Array[Node2D]) -> void:
	for enemy in enemies_hit:
		enemy.die()


func _on_player_moved() -> void:
	get_tree().call_group("goblins", "move_to", _player.position)


func _on_timeout() -> void:
	var spawn_position: Vector2 = _spawn_point.position
	var goblin: Node2D = _goblin_scene.instantiate()
	add_child(goblin)

	goblin.position = spawn_position
	goblin.move_to(_player.position)