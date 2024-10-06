extends MenuItem

const escape_action = "escape"
const actions_to_erase = ["attack"]

@export var _menus: Array[Control]

@onready var _menu_open := true

var _active_menu: Control


func _ready() -> void:
	_active_menu = get_menu(menus.TITLE_SCREEN_MENU, _menus)

	_close_menu()
	_open_menu()

	for menu in _menus:
		menu.close_menu.connect(_on_close_menu)
		menu.transition_menu.connect(_on_transition_menu)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(escape_action):
		if not _menu_open:
			_open_menu()
		else:
			_close_menu()


func _open_menu() -> void:
	_menu_open = true

	for action in actions_to_erase:
		InputMap.erase_action(action)

	show()
	_active_menu.show()


func _close_menu() -> void:
	_menu_open = false

	InputMap.load_from_project_settings()
	_active_menu = get_menu(menus.TITLE_SCREEN_MENU, _menus)

	hide()
	_hide_all()
	

func _hide_all():
	for menu in _menus:
		menu.hide()


func _on_close_menu():
	_close_menu()


func _on_transition_menu(new_menu: String) -> void:
	_active_menu.hide()
	_active_menu = get_menu(new_menu, _menus)
	_active_menu.show()