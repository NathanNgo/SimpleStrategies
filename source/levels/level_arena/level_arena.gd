extends Node2D

@export var _player_scene: PackedScene
@export var _players: Node2D
@export var _player_spawn_point: Node2D


func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_player_connected)


func _on_enemies_hit(enemies_hit: Array[Node2D]) -> void:
	for enemy in enemies_hit:
		var enemy_id = enemy.id
		enemy.die.rpc()

		spawn_player(enemy_id)


func spawn_player(peer_id: int):
	print("[Info] %s Spawning player with name: %s" % [multiplayer.get_unique_id(), str(peer_id)])
	var player = _player_scene.instantiate()
	player.name = str(peer_id)
	player.player_id = peer_id
	player.position = _player_spawn_point.position
	player.enemies_hit.connect(_on_enemies_hit)

	_players.add_child(player, true)


func _on_player_connected(peer_id: int):
	spawn_player(peer_id)