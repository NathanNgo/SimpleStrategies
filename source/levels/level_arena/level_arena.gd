extends Node2D

@export var _player_scene: PackedScene
@export var _players: Node2D
@export var _player_spawn_point: Node2D


func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_player_connected)


func _on_enemies_hit(attacker: String, enemies_hit: Array[Node2D]) -> void:
	for enemy in enemies_hit:
		print("[Info] %s Attacked %s" % [attacker, enemy.name])
		enemy.die.rpc()


func _on_player_dead(player_id: int):
	spawn_player(player_id)


func spawn_player(peer_id: int):
	var player = _player_scene.instantiate()
	player.name = str(peer_id)
	player.player_id = peer_id
	player.position = _player_spawn_point.position
	player.enemies_hit.connect(_on_enemies_hit)
	player.player_dead.connect(_on_player_dead)

	_players.add_child(player, true)


func _on_player_connected(peer_id: int):
	spawn_player(peer_id)