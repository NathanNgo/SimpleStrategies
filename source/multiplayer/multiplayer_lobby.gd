extends Node


const PORT = 9123
const MAX_CONNECTIONS = 30

var local_id: int


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)


func create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CONNECTIONS)

	if error:
		print(error)
		return

	local_id = peer.get_unique_id()
	print("The host ID is %d" % local_id)
	multiplayer.multiplayer_peer = peer


func join_server(address: String = "localhost"):
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)

	if error:
		print(error)
		return error

	local_id = peer.get_unique_id()
	print("The client ID is %d" % local_id)
	print("The client joined %s" % address)
	multiplayer.multiplayer_peer = peer


@rpc("any_peer", "call_remote", "reliable")
func print_on_peer(message: String) -> void:
	print(message)


func _on_peer_connected(peer_id: int):
	print_on_peer.rpc_id(peer_id, "Connection from %d to %d" % [local_id, peer_id])