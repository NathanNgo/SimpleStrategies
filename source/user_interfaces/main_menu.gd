extends CanvasLayer

signal multiplayer_join(address: String)
signal multiplayer_host
signal game_resume

@export var _address_input: LineEdit
@export var _join_button: Button
@export var _host_button: Button
@export var _resume_button: Button


func _ready() -> void:
	_join_button.pressed.connect(_on_join_button_pressed)
	_host_button.pressed.connect(_on_host_button_pressed)
	_resume_button.pressed.connect(_on_resume_button_pressed)


func _on_resume_button_pressed():
	game_resume.emit()


func _on_join_button_pressed():
	var address := _address_input.text
	multiplayer_join.emit(address)


func _on_host_button_pressed():
	multiplayer_host.emit()