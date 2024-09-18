extends CanvasLayer

const escape_action = "escape"
const actions_to_erase = ["attack"]

@export var _address_input: LineEdit
@export var _join_button: Button
@export var _host_button: Button
@export var _resume_button: Button

@onready var menu_open := visible

func _ready() -> void:
	_join_button.pressed.connect(_on_join_button_pressed)
	_host_button.pressed.connect(_on_host_button_pressed)
	_resume_button.pressed.connect(_on_resume_button_pressed)

	if menu_open:
		_open_menu()
	else:
		_close_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(escape_action):
		if not menu_open:
			_open_menu()
		else:
			_close_menu()


func _open_menu() -> void:
	menu_open = true

	for action in actions_to_erase:
		InputMap.erase_action(action)

	show()


func _close_menu() -> void:
	menu_open = false
	InputMap.load_from_project_settings()
	hide()


func _on_resume_button_pressed() -> void:
	_close_menu()


func _on_join_button_pressed() -> void:
	var address := _address_input.text
	var return_code = MultiplayerLobby.join_server(address)

	if not return_code:
		_close_menu()


func _on_host_button_pressed() -> void:
	var return_code = MultiplayerLobby.create_server()

	if not return_code:
		_close_menu()