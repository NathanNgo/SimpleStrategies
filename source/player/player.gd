extends Node2D

signal player_areas_hit_from_player(attacker: String, player_areas: Array[Area2D])

@export var _camera: Camera2D
@export var _projectiles_container: Node2D
@export var _input_synchronizer: MultiplayerSynchronizer
@export var _player_bodies = {}

@export var player_name: String
@export var player_body_spawn_position: Vector2
@export var player_id: int:
	set(new_player_id):
		player_id = new_player_id
		_input_synchronizer.set_multiplayer_authority(new_player_id)

const characters = {
	WARRIOR = "WARRIOR",
	ARCHER = "ARCHER"
}
var current_player_body: PlayerBody2D = null
# Dict[StringName, Array[Area2D]]
var hitboxes_with_hittable_player_areas = {}


func setup(
	player_id_: int,
	player_body_spawn_position_: Vector2,
):
	self.player_id = player_id_
	self.player_body_spawn_position = player_body_spawn_position_


func _ready() -> void:
	_setup_player_bodies()
	switch_character(characters.ARCHER)

	if _input_synchronizer.is_multiplayer_authority():
		_camera.make_current()


func _process(_delta: float) -> void:
	_camera.position = current_player_body.position

	if _input_synchronizer.switch_character_one:
		switch_character(characters.WARRIOR)
	elif _input_synchronizer.switch_character_two:
		switch_character(characters.ARCHER)


func switch_character(character_selection: String):
	if get_node(_player_bodies[character_selection]) == current_player_body:
		return

	for player_body_key in _player_bodies:
		var player_body = get_node(_player_bodies[player_body_key])
		player_body.process_mode = Node.PROCESS_MODE_DISABLED
		player_body.hide()

	var previous_player_body_position = player_body_spawn_position
	if current_player_body:
		previous_player_body_position = current_player_body.position

	current_player_body = get_node(_player_bodies[character_selection])
	current_player_body.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_player_body.position = previous_player_body_position
	current_player_body.show()


func _setup_player_bodies(spawn_position := player_body_spawn_position):
	for player_body_key in _player_bodies:
		var player_body = get_node(_player_bodies[player_body_key])
		player_body.setup(
			_input_synchronizer,
			spawn_position
		)

		# Prevent puppets from having a signal handler. We want the host to run most logic.
		if is_multiplayer_authority():
			player_body.player_areas_hit.connect(_on_player_areas_hit)
			player_body.player_body_dead.connect(_on_player_body_dead)
			player_body.create_projectile.connect(_on_create_projectile)
			player_body.player_area_entered.connect(_on_player_area_entered)
			player_body.player_area_exited.connect(_on_player_area_exited)


func _respawn_player_body():
	current_player_body.hide()
	current_player_body.reset_player_body(player_body_spawn_position)
	current_player_body.show()


func _on_player_body_dead():
	_respawn_player_body()


func _on_player_area_entered(area: Area2D, hitbox_name: String) -> void:
	if area == current_player_body.player_body_area:
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


func _on_create_projectile(projectile: Area2D, spawn_position: Vector2, target_position: Vector2):
	_projectiles_container.add_child(projectile, true)
	projectile.setup(
		spawn_position,
		target_position
	)
	projectile.area_entered.connect(_on_projectile_area_entered)


func _on_projectile_area_entered(area: Area2D):
	if area == current_player_body.player_body_area:
		return

	var areas: Array[Area2D] = [area]
	player_areas_hit_from_player.emit(player_name, areas)