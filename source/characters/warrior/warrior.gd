extends PlayerBody2D

signal player_bodies_hit(attacker: String, player_bodies: Array[PlayerBody2D])
signal player_body_dead

@export var _animation_player: AnimationPlayer
@export var _sprites: Node2D
@export var _death_sprites: Sprite2D
@export var _warrior_sprites: Sprite2D
@export var _hitboxes: Node2D
@export var _camera: Camera2D

@export var walk_speed: int = 150
@export var dash_speed: int =  700
@export var max_dash_frames: int = 5

enum states {IDLE, WALKING, ATTACKING, DASHING, DEAD}
# Stringed Enum's aren't a thing yet :(
const animations = {
	IDLE = "idle",
	WALK = "walk",
	ATTACK_FORWARD = "attack_forward",
	ATTACK_DOWN = "attack_down",
	ATTACK_UP = "attack_up",
	DIE = "die",
}

var state = states.IDLE
var death_animation_finished = false
var total_dash_frames = 0
# Dict[String, Array[Node2D]]
var hitboxes_with_killable_enemies = {}


func setup(
	_input_synchronizer_: MultiplayerSynchronizer,
	position_: Vector2,
):
	self._input_synchronizer = _input_synchronizer_
	self.position = position_
	

func _ready() -> void:
	_death_sprites.hide()

	_animation_player.animation_attack.connect(_on_attack)
	_animation_player.animation_finished.connect(_on_animation_finished)

	for hitbox in _hitboxes.hitboxes:
		hitbox.body_entered.connect(_on_body_entered.bind(hitbox.hitbox_name))
		hitbox.body_exited.connect(_on_body_exited.bind(hitbox.hitbox_name))

	if _input_synchronizer.is_multiplayer_authority():
		_camera.make_current()


func _physics_process(_delta) -> void:
	match state:
		states.IDLE:
			if _input_synchronizer.attack:
				state = states.ATTACKING
				_attack(_get_direction_to_mouse())
			elif _is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.WALKING:
			if _input_synchronizer.attack:
				state = states.ATTACKING
				_attack(_get_direction_to_mouse())
			elif _input_synchronizer.dash:
				state = states.DASHING
				_dash()
			elif _is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.ATTACKING:
			if _input_synchronizer.attack:
				_attack(_get_direction_to_mouse())
			elif _is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.DASHING:
			if total_dash_frames < max_dash_frames:
				_dash()
			elif _is_move_action_pressed():
				total_dash_frames = 0
				state = states.WALKING
				_walk()
			else:
				total_dash_frames = 0
				state = states.IDLE
				_idle()

		states.DEAD:
			_die()


func _is_move_action_pressed() -> bool:
	return (
		_input_synchronizer.move_right or
		_input_synchronizer.move_left or
		_input_synchronizer.move_up or
		_input_synchronizer.move_down
	)


func _idle() -> void:
	_animation_player.play(animations.IDLE)


func _get_direction_to_mouse():
	var mouse_position = _input_synchronizer.mouse_position
	return position.direction_to(mouse_position)


func _attack(direction: Vector2) -> void:
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
	_animation_player.play(animations.WALK)
	_move_player(speed, set_scale_normal)


func _die():
	_warrior_sprites.hide()
	_death_sprites.show()
	_animation_player.play(animations.DIE)

	if death_animation_finished:
		player_body_dead.emit()


@rpc("any_peer", "call_local")
func die():
	state = states.DEAD


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == animations.DIE:
		death_animation_finished = true


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
		player_bodies_hit.emit(str(name), hitboxes_with_killable_enemies[hitbox_name])


func set_scale_normal(is_normal=true) -> void:
	if is_normal:
		_sprites.scale.x = SCALE_NORMAL
		_hitboxes.scale.x = SCALE_NORMAL
	else:
		_sprites.scale.x = SCALE_REVERSED
		_hitboxes.scale.x = SCALE_REVERSED