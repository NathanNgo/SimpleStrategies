extends CharacterBody2D

class_name PlayerBody2D

signal player_moved()
signal player_body_dead
signal body_entered(body: Node2D, hitbox_name: StringName)
signal body_exited(body: Node2D, hitbox_name: StringName)
signal player_bodies_hit(hitbox_name: StringName)
signal create_projectile(projectile: Node2D, spawn_position: Vector2, target_position: Vector2)


@export var walk_speed: int = 150
@export var input_synchronizer: MultiplayerSynchronizer
@export var hitboxes_container: Node2D = null

const SCALE_NORMAL := 1
const SCALE_REVERSED := -1
const AXIS_NEUTRAL := 0


func _ready() -> void:
	if not input_synchronizer:
		set_physics_process(false)
		set_process_input(false)
		set_process(false)

	if hitboxes_container:
		for hitbox in hitboxes_container.hitboxes:
			hitbox.body_entered.connect(_on_body_entered.bind(hitbox.name))
			hitbox.body_exited.connect(_on_body_exited.bind(hitbox.name))


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


func _on_body_entered(body: Node2D, hitbox_name: StringName) -> void:
	body_entered.emit(body, hitbox_name)


func _on_body_exited(body: Node2D, hitbox_name: StringName) -> void:
	body_exited.emit(body, hitbox_name)


func _on_player_bodies_hit(hitbox_name: StringName) -> void:
	player_bodies_hit.emit(hitbox_name)