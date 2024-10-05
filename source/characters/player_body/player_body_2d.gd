extends CharacterBody2D

class_name PlayerBody2D

signal player_moved()
signal player_body_dead
signal other_player_area_entered(body: Node2D, hitbox_name: StringName)
signal other_player_area_exited(body: Node2D, hitbox_name: StringName)
signal other_player_areas_hit(attacker_player_id: int, hitbox_name: StringName)
signal player_area_hit(attacker_player_id: int)
signal create_projectile(projectile: Node2D, spawn_position: Vector2, target_position: Vector2)


@export var walk_speed: int = 150
@export var hitboxes_container: Node2D
@export var player_body_area: Area2D
@export var sprites_container: Node2D

var input_synchronizer: MultiplayerSynchronizer
var killable := true

const SCALE_NORMAL := 1
const SCALE_REVERSED := -1
const AXIS_NEUTRAL := 0


func setup(
	input_synchronizer_: MultiplayerSynchronizer,
	position_: Vector2,
	player_team: int
):
	self.input_synchronizer = input_synchronizer_
	self.position = position_
	switch_player_body_color(player_team)


func _ready() -> void:
	if not is_multiplayer_authority():
		return

	if hitboxes_container:
		for hitbox in hitboxes_container.hitboxes:
			hitbox.area_entered.connect(_on_other_player_area_entered.bind(hitbox.name))
			hitbox.area_exited.connect(_on_other_player_area_exited.bind(hitbox.name))

	player_body_area.player_area_hit.connect(_on_player_area_hit)
	

func move_player_body(speed: int, set_scale_normal: Callable) -> void:
	var direction = Vector2.ZERO

	direction = input_synchronizer.direction

	if direction.x > AXIS_NEUTRAL:
		set_scale_normal.call(true)
	elif direction.x < AXIS_NEUTRAL:
		set_scale_normal.call(false)

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	player_moved.emit()


func is_move_action_pressed() -> bool:
	return (
		input_synchronizer.move_right or
		input_synchronizer.move_left or
		input_synchronizer.move_up or
		input_synchronizer.move_down
	)


func get_direction_to_mouse():
	var mouse_position = input_synchronizer.mouse_position
	return position.direction_to(mouse_position)


func switch_player_body_color(color_selection: int) -> void:
	sprites_container.switch_all_sprite_colors(color_selection)


func _on_other_player_area_entered(area: Area2D, hitbox_name: String) -> void:
	other_player_area_entered.emit(area, hitbox_name)


func _on_other_player_area_exited(area: Node2D, hitbox_name: StringName) -> void:
	other_player_area_exited.emit(area, hitbox_name)


func _on_other_player_areas_hit(hitbox_name: StringName) -> void:
	other_player_areas_hit.emit(hitbox_name)


func _on_player_area_hit(attacker_player_id: int) -> void:
	player_area_hit.emit(attacker_player_id)