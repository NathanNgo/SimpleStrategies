extends Node2D

signal other_areas_hit_from_player(attacker_player_id: int, player_areas: Array[Area2D], is_projectile: bool)

@export var _camera: Camera2D
@export var _projectiles_container: Node2D
@export var _input_synchronizer: MultiplayerSynchronizer
@export var _player_bodies = {}
@export var _spawn_protection_timer: Timer
@export var _objective_banner: CanvasLayer
@export var _objective_banner_timer: Timer

@export var player_name: String
@export var player_team: int
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
var banner_shown = false


func setup(
	player_id_: int,
	player_body_spawn_position_: Vector2,
	player_team_: int,
):
	self.player_id = player_id_
	self.player_body_spawn_position = player_body_spawn_position_
	self.player_team = player_team_

	PlayerRegistry.add_player(self.player_id, self)


func _ready() -> void:
	_setup_player_bodies()
	_objective_banner.hide()
	_objective_banner_timer.timeout.connect(_on_objective_banner_timeout)

	if is_multiplayer_authority():
		switch_character(characters.ARCHER)
		_spawn_protection_timer.timeout.connect(_on_spawn_protection_timer_timeout)

	if _input_synchronizer.is_multiplayer_authority():
		_camera.make_current()


func _process(_delta: float) -> void:
	if _input_synchronizer.is_multiplayer_authority():
		if not banner_shown:
			_objective_banner.show()

	if not is_multiplayer_authority():
		return

	_camera.position = current_player_body.position


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if _input_synchronizer.switch_character_one:
		switch_character(characters.WARRIOR)
	elif _input_synchronizer.switch_character_two:
		switch_character(characters.ARCHER)


func switch_character(character_selection: String) -> void:
	if get_player_body(character_selection) == current_player_body:
		return

	if not current_player_body:
		current_player_body = get_player_body(character_selection)

	if current_player_body.state == current_player_body.states.DEAD:
		return

	for player_body_key in _player_bodies:
		var player_body = get_player_body(player_body_key)
		player_body.process_mode = Node.PROCESS_MODE_DISABLED
		player_body.hide()

	var previous_player_body_position = current_player_body.position
	current_player_body = get_player_body(character_selection)
	current_player_body.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_player_body.position = previous_player_body_position
	current_player_body.show()


func get_player_body(character_selection: String):
	return get_node(_player_bodies[character_selection])


func _setup_player_bodies(spawn_position := player_body_spawn_position) -> void:
	for player_body_key in _player_bodies:
		var player_body = get_node(_player_bodies[player_body_key])
		player_body.setup(
			_input_synchronizer,
			spawn_position,
			player_team
		)

		# Prevent puppets from having a signal handler. We want the host to run most logic.
		if is_multiplayer_authority():
			player_body.other_areas_hit.connect(_on_other_areas_hit)
			player_body.player_body_dead.connect(_on_player_body_dead)
			player_body.create_projectile.connect(_on_create_projectile)
			player_body.other_area_entered.connect(_on_other_area_entered)
			player_body.other_area_exited.connect(_on_other_area_exited)
			player_body.player_area_hit.connect(_on_player_area_hit)


func _respawn_player_body() -> void:
	current_player_body.hide()
	current_player_body.reset_player_body(player_body_spawn_position)
	current_player_body.killable = false
	_spawn_protection_timer.start()
	current_player_body.show()


func _on_player_body_dead() -> void:
	_respawn_player_body()


func _on_other_area_entered(area: Area2D, hitbox_name: String) -> void:
	if area == current_player_body.player_body_area:
		return

	if not hitboxes_with_hittable_player_areas.has(hitbox_name):
		# Dicts are untyped, and type inference doesn't work if we don't
		# tell GDScript what type this array is meant to contain.
		# This can break functions expecting parameters of certain types.
		var empty_array: Array[Area2D] = []
		hitboxes_with_hittable_player_areas[hitbox_name] = empty_array

	hitboxes_with_hittable_player_areas[hitbox_name].append(area)


func _on_other_area_exited(area: Area2D, hitbox_name: String) -> void:
	if not hitboxes_with_hittable_player_areas.has(hitbox_name):
		var empty_array: Array[Area2D] = []
		hitboxes_with_hittable_player_areas[hitbox_name] = empty_array

	hitboxes_with_hittable_player_areas[hitbox_name].erase(area)


func _on_other_areas_hit(hitbox_name: String) -> void:
	if hitboxes_with_hittable_player_areas.has(hitbox_name):
		other_areas_hit_from_player.emit(player_id, hitboxes_with_hittable_player_areas[hitbox_name], false)


func _on_create_projectile(projectile: Area2D, spawn_position: Vector2, target_position: Vector2) -> void:
	_projectiles_container.add_child(projectile, true)
	projectile.setup(
		spawn_position,
		target_position
	)
	projectile.area_entered.connect(_on_projectile_other_area_entered)


func _on_projectile_other_area_entered(area: Area2D) -> void:
	if area == current_player_body.player_body_area:
		return

	var areas: Array[Area2D] = [area]
	other_areas_hit_from_player.emit(player_id, areas, true)


func _on_spawn_protection_timer_timeout() -> void:
	for player_body_key in _player_bodies:
		var player_body = get_node(_player_bodies[player_body_key])
		player_body.killable = true


func _on_player_area_hit(attacker_player_id: int):
	var attacker: Node2D = PlayerRegistry.get_player(attacker_player_id)
	var attacker_team: int = attacker.player_team
	
	if attacker_team == player_team:
		return

	current_player_body.hit()


func _on_objective_banner_timeout():
	banner_shown = true
	_objective_banner.hide()