extends CharacterBody2D

class_name PlayerBody2D

signal player_moved()

@export var _input_synchronizer: MultiplayerSynchronizer

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