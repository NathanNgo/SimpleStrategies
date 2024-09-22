extends CharacterBody2D

class_name PlayerBody2D

signal player_moved()
signal player_body_dead
signal body_entered(body: Node2D, hitbox_name: StringName)
signal body_exited(body: Node2D, hitbox_name: StringName)
signal player_bodies_hit(hitbox_name: StringName)
signal create_projectile(projectile: Node2D)


@export var _input_synchronizer: MultiplayerSynchronizer
@export var walk_speed: int = 150

const SCALE_NORMAL := 1
const SCALE_REVERSED := -1
const AXIS_NEUTRAL := 0


func _ready() -> void:
	if not _input_synchronizer:
		set_physics_process(false)
		set_process_input(false)
		set_process(false)


func _move_player(speed: int, set_scale_normal: Callable) -> void:
	var direction = Vector2.ZERO

	direction = _input_synchronizer.direction

	if direction.x > AXIS_NEUTRAL:
		set_scale_normal.call(true)
	elif direction.x < AXIS_NEUTRAL:
		set_scale_normal.call(false)

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	player_moved.emit()