extends MenuItem

@export var _address_input: LineEdit
@export var _connect_button: Button
@export var _back_button: Button


func _ready() -> void:
	_connect_button.pressed.connect(_on_connect_button_pressed)
	_back_button.pressed.connect(_on_back_button_pressed)


func _on_connect_button_pressed():
	var address := _address_input.text
	var return_code = MultiplayerLobby.join_server(address)

	if not return_code:
		close_menu.emit()


func _on_back_button_pressed():
	transition_menu.emit(menus.TITLE_SCREEN_MENU)