extends Node


var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909
var token
	
func connect_to_server(_ip = ip, _port = port):
	get_tree().network_peer = null
	network.create_client(_ip, _port)
	get_tree().set_multiplayer_peer(network)
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	Logger.INFO("connection to master server success")
	rpc_id(1, "connect_as_server")
	#fetch_player_inventory()
	
func _on_connection_failed():
	Logger.INFO("connection to master server fail")


@rpc("any_peer") func return_server_time(serverTime, clientTime):
	pass

@rpc("any_peer") func return_latency(clientTime):
	pass

@rpc("any_peer") func fetch_token():
	print("returning token")
	rpc_id(1, "return_token", token)

@rpc("any_peer") func return_token_verification_results(result):
	if result == true:
		print("successful token verification")
	else:
		print("login failed; try again")

#server calls for player info
func fetch_player_inventory():
	rpc_id(1, "fetch_player_inventory")
	
@rpc("any_peer") func get_lobby_players(lobbyId, players):
	pass
