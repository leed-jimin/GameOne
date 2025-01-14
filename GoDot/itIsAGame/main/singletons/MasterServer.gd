extends Node

var Player_Stats = preload("res://main/userDetails/PlayerStats.tscn")

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909
var token

var clientClock = 0
var decimalCollector : float = 0
var latencyArray = []
var latency = 0
var deltaLatency = 0
	
func _physics_process(delta):
	clientClock += int(delta * 1000) + deltaLatency
	deltaLatency = 0 
	decimalCollector += (delta * 1000) - int(delta * 1000)
	if decimalCollector >= 1.00:
		clientClock += 1
		decimalCollector -= 1.00
	
func connect_to_server():
	#multiplayer.network_peer = null
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

@rpc("any_peer") func connect_to_game(_ip, _port):
	GameServer.connect_to_server(_ip, _port)

func _on_connection_succeeded():
	Log.INFO("connection to masterserver success")
	#fetch_player_inventory()
	
func _on_connection_failed():
	Log.INFO("connection to masterserver fail")

func determine_latency():
	rpc_id(1, "determine_latency", Time.get_ticks_msec())

@rpc("any_peer") func return_server_time(serverTime, clientTime):
	latency = (Time.get_ticks_msec() - clientTime) / 2
	clientClock = serverTime + latency

@rpc("any_peer") func return_latency(clientTime):
	latencyArray.append((Time.get_ticks_msec() - clientTime) / 2)
	if latencyArray.size() == 9:
		var totalLatency = 0
		latencyArray.sort()
		var midPoint = latencyArray[4]
		for i in range(latencyArray.size()-1,-1,-1):
			if latencyArray[i] > (2 * midPoint) and latencyArray[i] > 20:
				latencyArray.remove(i)
			else:
				totalLatency += latencyArray[i]
		deltaLatency = (totalLatency / latencyArray.size()) - latency
		latency = totalLatency / latencyArray.size()
		#print("new latency", latency)
		latencyArray.clear()

@rpc("any_peer") func fetch_token():
	print("returning token")
	rpc_id(1, "return_token", token)

@rpc("any_peer") func return_token_verification_results(result):
	if result == true:
		get_node("/root/Main/LoginScreen").queue_free()
		get_node("/root/Main").player_verified()
		print("successful token verification")
		#self.custom_multiplayer.set_root_node(server);
	else:
		print("login failed; try again")
		get_node("MainScreen/NinePatchRect/VBoxContainer/LoginButton").disabled = false

#lobby calls
func create_lobby():
	rpc_id(1, "request_create_lobby")

@rpc("any_peer") func lobby_created(playerId, lobbyId):
	get_node("/root/Main").load_lobby("Create")
	
func join_lobby(lobbyId):
	rpc_id(1, "request_join_lobby", lobbyId)
	
@rpc("any_peer") func return_lobby_joined(playerId, lobbyId):
	get_node("/root/Main/Hub").join_lobby()
	pass
	
func leave_lobby(lobbyId):
	rpc_id(1, "request_leave_lobby", lobbyId)

@rpc("any_peer") func return_lobby_left():
	get_node("/root/Main/Lobby").switch_to_hub()
	pass

func request_start_game(lobbyId):
	rpc_id(1, "request_start_game", lobbyId)
	
@rpc("any_peer") func game_starting():
	pass
	
@rpc("any_peer") func start_game():
	pass
	
