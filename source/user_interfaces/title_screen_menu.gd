extends MenuItem

@export var _join_button: Button
@export var _host_button: Button
@export var _resume_button: Button


func _ready() -> void:
	_join_button.pressed.connect(_on_join_button_pressed)
	_host_button.pressed.connect(_on_host_button_pressed)
	_resume_button.pressed.connect(_on_resume_button_pressed)


func _on_join_button_pressed() -> void:
	transition_menu.emit(menus.MULTIPLAYER_MENU)


func _on_host_button_pressed() -> void:
	var return_code = MultiplayerLobby.create_server()

	if not return_code:
		close_menu.emit()


func _on_resume_button_pressed() -> void:
	close_menu.emit()