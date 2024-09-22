extends Node2D

signal player_bodies_hit_from_player(attacker: String, player_bodies: Array[Node2D])

@export var _warrior_scene: PackedScene
# @export var _archer_scene: PackedScene

@export var _camera: Camera2D
@export var _projectiles_container: Node2D
@export var _input_synchronizer: MultiplayerSynchronizer
@export var player_name: String
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
# Dict[StringName, Array[Node2D]]
var hitboxes_with_hittable_player_bodies = {}


func setup(
	player_id_: int,
	player_body_spawn_position_: Vector2,
):
	self.player_id = player_id_
	self.player_body_spawn_position = player_body_spawn_position_


func _ready() -> void:
	_allocate_scenes()
	_spawn_player_body()

	if _input_synchronizer.is_multiplayer_authority():
		print(_input_synchronizer.get_multiplayer_authority())
		_camera.make_current()


func _process(_delta: float) -> void:
	_camera.position = player_body.position


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

	player_body.player_bodies_hit.connect(_on_player_bodies_hit)
	player_body.player_body_dead.connect(_on_player_body_dead)
	player_body.create_projectile.connect(_on_create_projectile)

	for hitbox in player_body.hitboxes_container.hitboxes:
		hitbox.body_entered.connect(_on_body_entered.bind(hitbox.name))
		hitbox.body_exited.connect(_on_body_exited.bind(hitbox.name))

	add_child(player_body)


func _on_player_body_dead():
	_spawn_player_body()


func _on_body_entered(body: Node2D, hitbox_name: String) -> void:
	if body == player_body:
		return

	if !hitboxes_with_hittable_player_bodies.has(hitbox_name):
		# Dicts are untyped, and type inference doesn't work if we don't
		# tell GDScript what type this array is meant to contain.
		# This can break functions expecting parameters of certain types.
		var empty_array: Array[PlayerBody2D] = []
		hitboxes_with_hittable_player_bodies[hitbox_name] = empty_array

	hitboxes_with_hittable_player_bodies[hitbox_name].append(body)


func _on_body_exited(body: Node2D, hitbox_name: String) -> void:
	if !hitboxes_with_hittable_player_bodies.has(hitbox_name):
		var empty_array: Array[PlayerBody2D] = []
		hitboxes_with_hittable_player_bodies[hitbox_name] = empty_array

	hitboxes_with_hittable_player_bodies[hitbox_name].erase(body)


func _on_player_bodies_hit(hitbox_name: String) -> void:
	if hitboxes_with_hittable_player_bodies.has(hitbox_name):
		player_bodies_hit_from_player.emit(player_name, hitboxes_with_hittable_player_bodies[hitbox_name])


func _on_create_projectile(projectile: Node2D):
	_projectiles_container.add_child(projectile)