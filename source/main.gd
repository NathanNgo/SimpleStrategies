extends Node

@export var _main_menu: CanvasLayer

@onready var menu_open := _main_menu.visible

const escape_action = "escape"
const actions_to_erase = ["attack"]


func _ready() -> void:
	_main_menu.multiplayer_host.connect(_on_multiplayer_host)
	_main_menu.multiplayer_join.connect(_on_multiplayer_join)
	_main_menu.game_resume.connect(_on_game_resume)

	if menu_open:
		_open_menu()
	else:
		_close_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(escape_action):
		if not menu_open:
			_open_menu()
		else:
			_close_menu()


func _open_menu():
	menu_open = true

	for action in actions_to_erase:
		InputMap.erase_action(action)

	_main_menu.show()


func _close_menu():
	menu_open = false
	InputMap.load_from_project_settings()
	_main_menu.hide()


func _on_multiplayer_host() -> void:
	MultiplayerLobby.create_server()


func _on_multiplayer_join(address: String) -> void:
	MultiplayerLobby.join_server(address)


func _on_game_resume() -> void:
	_close_menu()