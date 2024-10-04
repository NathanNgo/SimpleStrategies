extends Node


func log(message: String):
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var minute = time.minute
	var second = time.second

	var peer_id = multiplayer.get_unique_id()

	print(
		"[Info | Time %d:%d:%d | Peer ID %d | Authority %s] %s" % [
			hour, minute, second, peer_id, is_multiplayer_authority(), message
		]
	)