extends Area2D


@export var _timer: Timer

@export var arrow_speed = 1400
@export var velocity: Vector2

var direction: Vector2
var target_position: Vector2
var spawn_position: Vector2


func _ready() -> void:
	if is_multiplayer_authority():
		_timer.timeout.connect(_on_timeout)


func setup(spawn_position_, target_position_):
	self.target_position = target_position_
	self.spawn_position = spawn_position_
	self.position = self.spawn_position
	self.rotation = get_angle_to(self.target_position)

	direction = spawn_position.direction_to(target_position)
	direction = direction.normalized()
	velocity = arrow_speed * direction


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		position = position + velocity * delta


func _on_timeout():
	queue_free()