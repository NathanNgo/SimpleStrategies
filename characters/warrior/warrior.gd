extends CharacterBody2D


@onready var _animated_sprite = $AnimatedSprite2D
@export var speed: int = 150

func _process(delta):
	var direction = Vector2.ZERO
	var attacking = false

	if Input.is_action_pressed("move_right"):
		_animated_sprite.flip_h = false
		direction.x += 1
	elif Input.is_action_pressed("move_left"):
		_animated_sprite.flip_h = true
		direction.x -= 1

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		direction.y += 1

	if Input.is_action_pressed("attack"):
		direction = Vector2.ZERO
		attacking = true

	if not attacking:
		if direction == Vector2.ZERO:
			_animated_sprite.play("idle")
		else:
			_animated_sprite.play("run")
	else:
		_animated_sprite.play("attack_forward")


	direction = direction.normalized()
	position += direction * speed * delta