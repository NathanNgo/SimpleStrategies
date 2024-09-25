extends Node


signal player_connected(peer_id: int)


const PORT = 9123
const MAX_CONNECTIONS = 30

var local_id: int


func create_server():
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CONNECTIONS)

	if error:
		print(error)
		return error

	local_id = peer.get_unique_id()

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)

	player_connected.emit(local_id)

	upnp_setup()


func join_server(address: String = "localhost"):
	# You'd think the default argument value would do it. It doesn't.
	address = address if address else "localhost"
	print("[Info] Attempting to join: %s" % address)

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)

	if error:
		print(error)
		return error

	local_id = peer.get_unique_id()
	multiplayer.multiplayer_peer = peer


func _on_peer_connected(peer_id: int) -> void:
	print("[Info] Peer joined as: %d" % peer_id)
	player_connected.emit(peer_id)


func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(
		discover_result == UPNP.UPNP_RESULT_SUCCESS,
		"[Error] UPNP Discovery Failed: %s" % discover_result
	)

	assert(
		upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(),
		"[Error] UPNP Invalid Gateway"
	)

	var map_result = upnp.add_port_mapping(PORT)
	assert(
		map_result == UPNP.UPNP_RESULT_SUCCESS,
		"[Error] UPNP Port Mapping Failed: %s" % map_result
	)
	
	print("[Info] UPNP Succeeded: %s" % upnp.query_external_address())