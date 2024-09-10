extends CharacterBody2D


@export var _navigation_agent_2d: NavigationAgent2D
@export var _animated_sprite_2d: AnimatedSprite2D
@export var _collision_shape_2d: CollisionShape2D

@export var speed: int = 50
var alive = true
const death_animation_frame_amount = 13


func _ready():
	_animated_sprite_2d.play("idle")

	call_deferred("actor_setup")


func actor_setup():
	await get_tree().physics_frame


func _physics_process(_delta):
	if not alive:
		_animated_sprite_2d.play("die")
		
		if _animated_sprite_2d.frame == death_animation_frame_amount:
			queue_free()

		return

	if _navigation_agent_2d.is_target_reached():
		_animated_sprite_2d.play("idle")
		return

	var current_position: Vector2 = global_position
	var next_path_position: Vector2 = _navigation_agent_2d.get_next_path_position()

	velocity = current_position.direction_to(next_path_position) * speed


	if velocity.length() != 0:
		_animated_sprite_2d.play("run")

	move_and_slide()


func move_to(target_position: Vector2):
	_navigation_agent_2d.target_position = target_position


func die():
	_collision_shape_2d.disabled = true
	alive = false