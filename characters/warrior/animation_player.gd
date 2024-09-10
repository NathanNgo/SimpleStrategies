extends AnimationPlayer

signal animation_attack


func attack(hitbox_name: String):
	animation_attack.emit(hitbox_name)