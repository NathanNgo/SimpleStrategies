extends Node2D

signal player_bodies_hit(attacker: String, player_bodies: Array[Node2D])

@export var _warrior_scene: PackedScene
# @export var _archer_scene: PackedScene
@export var _input_synchronizer: MultiplayerSynchronizer
@export var player_id: int:
	set(new_player_id):
		player_id = new_player_id
		_input_synchronizer.set_multiplayer_authority(new_player_id)

enum characters {
	WARRIOR,
	# ARCHER
}
var character := characters.WARRIOR
var player_body: PlayerBody2D = null
var player_body_spawn_position: Vector2
var characters_scenes: Array[PackedScene]


func setup(
	player_id_: int,
	player_body_spawn_position_: Vector2,
):
	self.player_id = player_id_
	self.player_body_spawn_position = player_body_spawn_position_


func _ready() -> void:
	_allocate_scenes()
	_spawn_player_body()

	player_body.player_bodies_hit.connect(_on_player_bodies_hit)
	player_body.player_body_dead.connect(_on_player_body_dead)


func switch_character(character_selection: characters):
	character = character_selection
	_spawn_player_body()


func _allocate_scenes():
	characters_scenes = [
		_warrior_scene,
		# _archer_scene
	]


func _spawn_player_body():
	if player_body:
		player_body.queue_free()

	player_body = characters_scenes[character].instantiate()
	player_body.setup(
		_input_synchronizer,
		player_body_spawn_position
	)
	add_child(player_body)


func player_body_hit():
	player_body.die()


func _on_player_bodies_hit(attacker: String, player_bodies: Array[Node2D]):
	player_bodies_hit.emit(attacker, player_bodies)


func _on_player_body_dead():
	_spawn_player_body()