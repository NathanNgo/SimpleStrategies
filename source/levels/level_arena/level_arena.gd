extends Node2D

@export var _player_scene: PackedScene
@export var _players: Node2D
@export var _player_spawn_points: Array[Node2D]

var total_number_of_players := 0
const MAX_TEAMS := 2

func _ready() -> void:
	MultiplayerLobby.player_connected.connect(_on_player_connected)


func _on_other_player_areas_hit_from_player(attacker_player_id: int, player_areas: Array[Area2D], is_projectile: bool) -> void:
	for player_area in player_areas:
		player_area.hit(attacker_player_id, is_projectile)


func create_player(peer_id: int):
	total_number_of_players += 1

	var player_team = total_number_of_players % MAX_TEAMS
	var spawn_point = _player_spawn_points[player_team]
	
	var player = _player_scene.instantiate()
	player.setup(
		peer_id,
		spawn_point.position,
		player_team
	)
	player.other_player_areas_hit_from_player.connect(_on_other_player_areas_hit_from_player)

	_players.add_child(player, true)


func _on_player_connected(peer_id: int):
	create_player(peer_id)