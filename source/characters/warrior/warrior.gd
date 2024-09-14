extends CharacterBody2D

signal player_moved()
signal enemies_hit(enemies_hit: Array[Node2D])

@export var _animation_player: AnimationPlayer
@export var _sprite: Sprite2D
@export var _hitboxes: Node2D
@export var walk_speed: int = 150
@export var dash_speed: int =  700
@export var max_dash_frames: int = 5

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
const SCALE_NORMAL = 1
const SCALE_REVERSED = -1
const AXIS_NEUTRAL = 0


var state = states.IDLE
var total_dash_frames = 0
# Dict[String, Array[Node2D]]
var hitboxes_with_killable_enemies = {}


func _ready() -> void:
	_animation_player.animation_attack.connect(_on_attack)

	for hitbox in _hitboxes.hitboxes:
		hitbox.body_entered.connect(_on_body_entered.bind(hitbox.hitbox_name))
		hitbox.body_exited.connect(_on_body_exited.bind(hitbox.hitbox_name))


func _physics_process(_delta) -> void:
	match state:
		states.IDLE, states.WALKING:
			if _is_attack_action_pressed():
				state = states.ATTACKING
				_attack()
			elif (_is_move_action_pressed()):
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.ATTACKING:
			if _is_attack_action_pressed():
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


func _unhandled_input(event: InputEvent) -> void:
	match state:
		states.WALKING:
			if event.is_action_pressed(input.DASH):
				state = states.DASHING
				_dash()


func _is_attack_action_pressed() -> bool:
	return (
		InputMap.has_action(input.ATTACK) and
		Input.is_action_pressed(input.ATTACK)
	)


func _is_move_action_pressed() -> bool:
	return (
		Input.is_action_pressed(input.RIGHT) or
		Input.is_action_pressed(input.LEFT) or
		Input.is_action_pressed(input.UP) or
		Input.is_action_pressed(input.DOWN)
	)


func _idle() -> void:
	_animation_player.play(animations.IDLE)


func _attack() -> void:
	var mouse_position = get_global_mouse_position()
	var direction = position.direction_to(mouse_position)

	if abs(direction.x) > abs(direction.y):
		if direction.x > AXIS_NEUTRAL:
			set_scale_normal(true)
		else:
			set_scale_normal(false)

		_animation_player.play(animations.ATTACK_FORWARD)
	else:
		if direction.y > AXIS_NEUTRAL:
			_animation_player.play(animations.ATTACK_DOWN)
		else:
			_animation_player.play(animations.ATTACK_UP)


func _dash() -> void:
	total_dash_frames += 1
	_move(dash_speed)


func _walk() -> void:
	_move(walk_speed)


func _move(speed: int) -> void:
	var direction = Vector2.ZERO

	direction.x = Input.get_axis(input.LEFT, input.RIGHT)
	direction.y = Input.get_axis(input.UP, input.DOWN)

	if direction.x > AXIS_NEUTRAL:
		set_scale_normal(true)
	else:
		set_scale_normal(false)

	_animation_player.play(animations.WALK)

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	player_moved.emit()


func _on_body_entered(body: Node2D, hitbox_name: String) -> void:
	if body == self:
		return

	if !hitboxes_with_killable_enemies.has(hitbox_name):
		# Dicts are untyped, and type inference doesn't work if we don't
		# tell GDScript what type this array is meant to contain.
		# This can break functions expecting parameters of certain types.
		var empty_array: Array[Node2D] = []
		hitboxes_with_killable_enemies[hitbox_name] = empty_array

	hitboxes_with_killable_enemies[hitbox_name].append(body)


func _on_body_exited(body: Node2D, hitbox_name: String) -> void:
	if !hitboxes_with_killable_enemies.has(hitbox_name):
		var empty_array: Array[Node2D] = []
		hitboxes_with_killable_enemies[hitbox_name] = empty_array

	hitboxes_with_killable_enemies[hitbox_name].erase(body)


func _on_attack(hitbox_name: String) -> void:
	if hitboxes_with_killable_enemies.has(hitbox_name):
		enemies_hit.emit(hitboxes_with_killable_enemies[hitbox_name])


func set_scale_normal(normal=true) -> void:
	if normal:
		_sprite.scale.x = SCALE_NORMAL
		_hitboxes.scale.x = SCALE_NORMAL
	else:
		_sprite.scale.x = SCALE_REVERSED
		_hitboxes.scale.x = SCALE_REVERSED

