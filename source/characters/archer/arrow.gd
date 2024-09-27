extends Area2D

@export var arrow_speed = 1400

var direction: Vector2
var velocity: Vector2
var target_position: Vector2
var spawn_position: Vector2


func setup(spawn_position_, target_position_):
	self.target_position = target_position_
	self.spawn_position = spawn_position_
	self.position = self.spawn_position

	look_at(target_position)
	direction = spawn_position.direction_to(target_position)
	direction = direction.normalized()
	velocity = arrow_speed * direction

func _physics_process(delta: float) -> void:
	position = position + velocity * delta