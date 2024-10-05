extends Node2D


@export var _animation_player: AnimationPlayer
@export var _tree_area: Area2D

@export var health := 100

var is_hit: = false


func _ready() -> void:
	print(is_multiplayer_authority())
	if not is_multiplayer_authority():
		return

	_animation_player.animation_finished.connect(_on_animation_finished)
	_tree_area.objective_area_hit.connect(_on_objective_area_hit)


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not is_hit:
		_animation_player.play("idle")
	elif health <= 0:
		_animation_player.play("cut")
	else:
		_animation_player.play("hit")


func hit():
	if health > 0:
		is_hit = true
		health -= 1


func _on_animation_finished(animation_name: String):
	if animation_name == "hit":
		is_hit = false
		_animation_player.play("idle")


func _on_objective_area_hit(attacker_player_id: int, is_projectile: bool):
	var attacker: Node2D = PlayerRegistry.get_player(attacker_player_id)

	if attacker.current_player_body != attacker.get_player_body(attacker.characters.WARRIOR):
		return

	if is_projectile:
		return

	hit()