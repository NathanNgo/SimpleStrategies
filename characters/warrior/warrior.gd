extends CharacterBody2D

signal player_moved()
signal enemies_hit(enemies_hit: Array[Node2D])

@export var _animation_player: AnimationPlayer
@export var _sprite: Sprite2D
@export var _hitboxes: Array[Area2D]
@export var walk_speed: int = 150
@export var dash_speed: int = 400
@export var max_dash_frames: int = 3

enum states {IDLE, WALKING, ATTACKING, DASHING}
# Stringed Enum's aren't a thing yet :(
const animations = {
	IDLE = "idle",
	WALK = "walk",
	ATTACK_FORWARD = "attack_forward",
	ATTACK_DOWN = "attack_down",
	ATTACK_UP = "attack_up",
}
const input = {
	UP = "move_up",
	DOWN = "move_down",
	RIGHT = "move_right",
	LEFT = "move_left",
	ATTACK = "attack",
	DASH = "dash"
}

var state = states.IDLE
var total_dash_frames = 0
# Dict[String, Array[Node2D]]
var hitboxes_with_killable_enemies = {}


func _ready():
	_animation_player.animation_attack.connect(_on_attack)

	for hitbox in _hitboxes:
		hitbox.body_entered.connect(_on_body_entered.bind(hitbox.hitbox_name))
		hitbox.body_exited.connect(_on_body_exited.bind(hitbox.hitbox_name))


func _physics_process(_delta):
	print(hitboxes_with_killable_enemies)
	match state:
		states.IDLE, states.WALKING:
			if Input.is_action_pressed(input.ATTACK):
				state = states.ATTACKING
				_attack()
			elif (_is_move_action_pressed()):
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.ATTACKING:
			if Input.is_action_pressed(input.ATTACK):
				_attack()
			elif (_is_move_action_pressed()):
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.DASHING:
			if total_dash_frames < max_dash_frames:
				_dash()
			elif (_is_move_action_pressed()):
				total_dash_frames = 0
				state = states.WALKING
				_walk()
			else:
				total_dash_frames = 0
				state = states.IDLE
				_idle()


func _input(event):
	match state:
		states.WALKING:
			if event.is_action_pressed(input.DASH):
				state = states.DASHING
				_dash()


func _is_move_action_pressed():
	return (
		Input.is_action_pressed(input.RIGHT) ||
		Input.is_action_pressed(input.LEFT) ||
		Input.is_action_pressed(input.UP) ||
		Input.is_action_pressed(input.DOWN)
	)


func _idle():
	_animation_player.play(animations.IDLE)


func _attack():
	var mouse_position = get_global_mouse_position()
	var direction = position.direction_to(mouse_position)
	
	_animation_player.play(animations.ATTACK_DOWN)
	# if _animation_player.frame in killable_frames:
	# 	enemy_hit.emit(killable_enemies)
	pass


func _dash():
	total_dash_frames += 1
	_move(dash_speed)


func _walk():
	_move(walk_speed)


func _move(speed: int):
	var direction = Vector2.ZERO

	direction.x = Input.get_axis(input.LEFT, input.RIGHT)
	direction.y = Input.get_axis(input.UP, input.DOWN)

	if direction.x:
		_sprite.scale.x = direction.x

	_animation_player.play(animations.WALK)

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	player_moved.emit()


func _on_body_entered(body: Node2D, hitbox_name: String):
	if !hitboxes_with_killable_enemies.has(hitbox_name):
		# Dicts are untyped, and type inference doesn't work if we don't
		# tell GDScript what type this array is meant to contain.
		# This can break functions expecting parameters of certain types.
		var empty_array: Array[Node2D] = []
		hitboxes_with_killable_enemies[hitbox_name] = empty_array

	hitboxes_with_killable_enemies[hitbox_name].append(body)


func _on_body_exited(body: Node2D, hitbox_name: String):
	if !hitboxes_with_killable_enemies.has(hitbox_name):
		var empty_array: Array[Node2D] = []
		hitboxes_with_killable_enemies[hitbox_name] = empty_array

	hitboxes_with_killable_enemies[hitbox_name].erase(body)


func _on_attack(hitbox_name: String):
	if hitboxes_with_killable_enemies.has(hitbox_name):
		enemies_hit.emit(hitboxes_with_killable_enemies[hitbox_name])
