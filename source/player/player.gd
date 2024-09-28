extends Node2D

signal player_areas_hit_from_player(attacker: String, player_areas: Array[Area2D])

@export var _warrior_scene: PackedScene
@export var _archer_scene: PackedScene

@export var _camera: Camera2D
@export var _projectiles_container: Node2D
@export var _input_synchronizer: MultiplayerSynchronizer
@export var player_name: String
@export var player_body_spawn_position: Vector2
@export var player_id: int:
	set(new_player_id):
		player_id = new_player_id
		_input_synchronizer.set_multiplayer_authority(new_player_id)

enum characters {
	WARRIOR,
	ARCHER
}
var character := characters.ARCHER
var player_body: PlayerBody2D = null
var characters_scenes: Array[PackedScene]
# Dict[StringName, Array[Area2D]]
var hitboxes_with_hittable_player_areas = {}


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
		_camera.make_current()


func _process(_delta: float) -> void:
	_camera.position = player_body.position


func switch_character(character_selection: characters):
	character = character_selection
	_spawn_player_body()


func _allocate_scenes():
	characters_scenes = [
		_warrior_scene,
		_archer_scene
	]


func _spawn_player_body():
	if player_body:
		player_body.queue_free()

	player_body = characters_scenes[character].instantiate()
	player_body.setup(
		_input_synchronizer,
		player_body_spawn_position
	)

	# Prevent puppets from having a signal handler. We want the host to run most logic.
	if is_multiplayer_authority():
		player_body.player_areas_hit.connect(_on_player_areas_hit)
		player_body.player_body_dead.connect(_on_player_body_dead)
		player_body.create_projectile.connect(_on_create_projectile)
		player_body.player_area_entered.connect(_on_player_area_entered)
		player_body.player_area_exited.connect(_on_player_area_exited)

	add_child(player_body)


func _respawn_player_body():
	player_body.hide()
	player_body.reset_player_body(player_body_spawn_position)
	player_body.show()


func _on_player_body_dead():
	_respawn_player_body()


func _on_player_area_entered(area: Area2D, hitbox_name: String) -> void:
	if area == player_body.player_body_area:
		return

	if not hitboxes_with_hittable_player_areas.has(hitbox_name):
		# Dicts are untyped, and type inference doesn't work if we don't
		# tell GDScript what type this array is meant to contain.
		# This can break functions expecting parameters of certain types.
		var empty_array: Array[Area2D] = []
		hitboxes_with_hittable_player_areas[hitbox_name] = empty_array

	hitboxes_with_hittable_player_areas[hitbox_name].append(area)


func _on_player_area_exited(area: Area2D, hitbox_name: String) -> void:
	if not hitboxes_with_hittable_player_areas.has(hitbox_name):
		var empty_array: Array[Area2D] = []
		hitboxes_with_hittable_player_areas[hitbox_name] = empty_array

	hitboxes_with_hittable_player_areas[hitbox_name].erase(area)


func _on_player_areas_hit(hitbox_name: String) -> void:
	if hitboxes_with_hittable_player_areas.has(hitbox_name):
		player_areas_hit_from_player.emit(player_name, hitboxes_with_hittable_player_areas[hitbox_name])


func _on_create_projectile(projectile: Node2D, spawn_position: Vector2, target_position: Vector2):
	_projectiles_container.add_child(projectile, true)
	projectile.setup(
		spawn_position,
		target_position
	)
	projectile.area_entered.connect(_on_projectile_area_entered)


func _on_projectile_area_entered(area: Area2D):
	if area == player_body.player_body_area:
		return

	var areas: Array[Area2D] = []
	areas.append(area)
	player_areas_hit_from_player.emit(player_name, areas)