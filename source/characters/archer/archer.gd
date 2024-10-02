extends PlayerBody2D

@export var _animation_player: AnimationPlayer
@export var _sprites: Node2D
@export var _archer_separated_sprites: Node2D
@export var _archer_sprites: Sprite2D
@export var _death_sprites: Sprite2D
@export var _bow_pivot: Node2D
@export var _arrow_scene: PackedScene

@export var max_dash_frames := 5
@export var state := states.IDLE
@export var death_animation_finished := false

enum states {IDLE, WALKING, BOW_CHARGING, BOW_RELEASED, DEAD}
# Stringed Enum's aren't a thing yet :(
const animations = {
	IDLE = "idle",
	WALK = "walk",
	DIE = "die",
	BOW_CHARGING = "bow_charging",
	BOW_CHARGED = "bow_charged",
	BOW_RELEASING = "bow_releasing"
}

var arrow_created := false
var total_dash_frames := 0
var bow_reset := false
var bow_completely_charged := false
var bow_completely_released := false


func setup(
	input_synchronizer_: MultiplayerSynchronizer,
	position_: Vector2,
):
	self.input_synchronizer = input_synchronizer_
	self.position = position_
	

func _ready() -> void:
	super._ready()

	_death_sprites.hide()
	_show_archer_separated_sprites(false)

	_animation_player.animation_finished.connect(_on_animation_finished)

	if is_multiplayer_authority():
		player_body_area.player_area_hit.connect(_on_player_area_hit)


func _physics_process(_delta) -> void:
	if not input_synchronizer:
		return

	if not is_multiplayer_authority():
		return

	match state:
		states.IDLE, states.WALKING:
			if input_synchronizer.attack:
				_reset_bow()
				state = states.BOW_CHARGING
				_charge_bow()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				_idle()

		states.BOW_CHARGING:
			if not bow_reset:
				_reset_bow()
				bow_reset = true

			if input_synchronizer.attack:
				_charge_bow()
			elif bow_completely_charged:
				state = states.BOW_RELEASED
				_release_bow()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.BOW_RELEASED:
			if not bow_completely_released:
				_release_bow()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.DEAD:
			_die()


func _reset_bow():
	bow_completely_charged = false
	bow_completely_released = false
	arrow_created = false


func _idle() -> void:
	_show_archer_alive_sprites(true)
	_show_archer_separated_sprites(false)
	_animation_player.play(animations.IDLE)


func _charge_bow() -> void:
	_aim()

	if not bow_completely_charged:
		_animation_player.play(animations.BOW_CHARGING)
	else:
		_animation_player.play(animations.BOW_CHARGED)


func _release_bow() -> void:
	_aim()

	if not arrow_created:
		var arrow = _arrow_scene.instantiate()
		create_projectile.emit(
			arrow,
			_bow_pivot.global_position,
			input_synchronizer.mouse_position
		)
		arrow_created = true

	_animation_player.play(animations.BOW_RELEASING)


func _aim() -> void:
	_show_archer_alive_sprites(true)
	_show_archer_separated_sprites(true)
	var direction = get_direction_to_mouse()

	_bow_pivot.look_at(input_synchronizer.mouse_position)

	if direction.x > AXIS_NEUTRAL:
		set_scale_normal(true)
	else:
		set_scale_normal(false)


func _walk() -> void:
	_move(walk_speed)


func _move(speed: int) -> void:
	_show_archer_alive_sprites(true)
	_show_archer_separated_sprites(false)
	_animation_player.play(animations.WALK)
	move_player_body(speed, set_scale_normal)


func _die():
	_show_archer_alive_sprites(false)
	_animation_player.play(animations.DIE)

	if death_animation_finished:
		player_body_dead.emit()


func _set_player_state_to_dead():
	if not killable:
		return

	state = states.DEAD


func _on_player_area_hit():
	_set_player_state_to_dead()


func _on_animation_finished(animation_name: String) -> void:
	match animation_name:
		animations.DIE:
			death_animation_finished = true
			hide()
		animations.BOW_CHARGING:
			bow_completely_charged = true
			_animation_player.play(animations.BOW_CHARGED)
		animations.BOW_RELEASING:
			bow_completely_released = true
			bow_reset = false
			_animation_player.play(animations.IDLE)


func set_scale_normal(is_normal=true) -> void:
	if is_normal:
		_sprites.scale.x = SCALE_NORMAL
	else:
		_sprites.scale.x = SCALE_REVERSED


func reset_player_body(spawn_position):
	state = states.IDLE
	position = spawn_position
	death_animation_finished = false


func _show_archer_separated_sprites(is_showing := true):
	if is_showing:
		_archer_separated_sprites.show()
		_archer_sprites.hide()
	else:
		_archer_separated_sprites.hide()
		_archer_sprites.show()


func _show_archer_alive_sprites(alive := true):
	if alive:
		_death_sprites.hide()
		_archer_separated_sprites.show()
		_archer_sprites.show()
	else:
		_death_sprites.show()
		_archer_separated_sprites.hide()
		_archer_sprites.hide()