extends MultiplayerSynchronizer

const input = {
	UP = "move_up",
	DOWN = "move_down",
	RIGHT = "move_right",
	LEFT = "move_left",
	ATTACK = "attack",
	DASH = "dash",
	SWITCH_CHARACTER_ONE = "switch_character_one",
	SWITCH_CHARACTER_TWO = "switch_character_two"
}

@export var _mouse_position_finder: Node2D

@export var attack: bool = false
@export var move_left: bool = false
@export var move_right: bool = false
@export var move_up: bool = false
@export var move_down: bool = false
@export var dash: bool = false
@export var switch_character_one: bool = false
@export var switch_character_two: bool = false

@export var direction: Vector2 = Vector2(0, 0)
@export var mouse_position: Vector2 = Vector2(0, 0)


func _ready() -> void:
	var is_enabled = get_multiplayer_authority() == multiplayer.get_unique_id()
	set_physics_process(is_enabled)


func _physics_process(_delta: float) -> void:
	move_right = Input.is_action_pressed(input.RIGHT)
	move_left = Input.is_action_pressed(input.LEFT)
	move_up = Input.is_action_pressed(input.UP)
	move_down = Input.is_action_pressed(input.DOWN)
	direction = Vector2(
		Input.get_axis(input.LEFT, input.RIGHT),
		Input.get_axis(input.UP, input.DOWN)
	)
	
	mouse_position = _mouse_position_finder.get_global_mouse_position()

	attack = InputMap.has_action(input.ATTACK) and Input.is_action_pressed(input.ATTACK)
	
	# Only true on the frame the action was pressed. Not persistent
	# even if the button is held down.
	dash = Input.is_action_just_pressed(input.DASH)

	switch_character_one = Input.is_action_just_pressed(input.SWITCH_CHARACTER_ONE)
	switch_character_two = Input.is_action_just_pressed(input.SWITCH_CHARACTER_TWO)