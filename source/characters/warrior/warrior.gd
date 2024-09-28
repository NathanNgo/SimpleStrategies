extends PlayerBody2D

@export var _animation_player: AnimationPlayer
@export var _sprites: Node2D
@export var _death_sprites: Sprite2D
@export var _warrior_sprites: Sprite2D

@export var dash_speed: int =  700
@export var max_dash_frames: int = 5
@export var state = states.IDLE
@export var death_animation_finished = false

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

var total_dash_frames = 0


func setup(
	input_synchronizer_: MultiplayerSynchronizer,
	position_: Vector2,
):
	self.input_synchronizer = input_synchronizer_
	self.position = position_
	

func _ready() -> void:
	super._ready()

	_death_sprites.hide()

	_animation_player.animation_attack.connect(_on_player_areas_hit)
	_animation_player.animation_finished.connect(_on_animation_finished)
	player_body_area.player_area_hit.connect(_on_player_area_hit)


func _physics_process(_delta) -> void:
	match state:
		states.IDLE:
			if input_synchronizer.attack:
				state = states.ATTACKING
				_attack()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.WALKING:
			if input_synchronizer.attack:
				state = states.ATTACKING
				_attack()
			elif input_synchronizer.dash:
				state = states.DASHING
				_dash()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.ATTACKING:
			if input_synchronizer.attack:
				_attack()
			elif is_move_action_pressed():
				state = states.WALKING
				_walk()
			else:
				state = states.IDLE
				_idle()

		states.DASHING:
			if total_dash_frames < max_dash_frames:
				_dash()
			elif is_move_action_pressed():
				total_dash_frames = 0
				state = states.WALKING
				_walk()
			else:
				total_dash_frames = 0
				state = states.IDLE
				_idle()

		states.DEAD:
			_die()


func _idle() -> void:
	_show_warrior_alive_sprites(true)
	_animation_player.play(animations.IDLE)


func _attack() -> void:
	_show_warrior_alive_sprites(true)
	var direction = get_direction_to_mouse()
	
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
	_show_warrior_alive_sprites(true)
	_animation_player.play(animations.WALK)
	move_player_body(speed, set_scale_normal)


func _die():
	_show_warrior_alive_sprites(false)
	_animation_player.play(animations.DIE)

	if death_animation_finished:
		player_body_dead.emit()


func _set_player_state_to_dead():
	state = states.DEAD


func _on_player_area_hit():
	_set_player_state_to_dead()


func _on_animation_finished(animation_name: String) -> void:
	match animation_name:
		animations.DIE:
			death_animation_finished = true


func set_scale_normal(is_normal=true) -> void:
	if is_normal:
		_sprites.scale.x = SCALE_NORMAL
		hitboxes_container.scale.x = SCALE_NORMAL
	else:
		_sprites.scale.x = SCALE_REVERSED
		hitboxes_container.scale.x = SCALE_REVERSED


func reset_player_body(spawn_position):
	state = states.IDLE
	position = spawn_position
	death_animation_finished = false


func _show_warrior_alive_sprites(alive := true):
	if alive:
		_death_sprites.hide()
		_warrior_sprites.show()
	else:
		_warrior_sprites.hide()
		_death_sprites.show()