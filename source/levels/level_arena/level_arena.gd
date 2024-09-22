extends Node2D

@export var _player_scene: PackedScene
@export var _players: Node2D
@export var _player_spawn_point: Node2D


func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_player_connected)


func _on_player_bodies_hit_from_player(_attacker: String, player_bodies: Array[PlayerBody2D]) -> void:
	for player_body in player_bodies:
		player_body.die.rpc()


func create_player(peer_id: int):
	var player = _player_scene.instantiate()
	player.setup(
		peer_id,
		_player_spawn_point.position,
	)
	player.player_bodies_hit_from_player.connect(_on_player_bodies_hit_from_player)

	_players.add_child(player, true)


func _on_player_connected(peer_id: int):
	create_player(peer_id)