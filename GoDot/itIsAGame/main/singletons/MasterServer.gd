extends Node

var Player_Stats = preload("res://main/userDetails/PlayerStats.tscn")

var network = NetworkedMultiplayerENet.new()
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
	get_tree().network_peer = null
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")

remote func connect_to_game(_ip, _port):
	GameServer.connect_to_server(_ip, _port)

func _on_connection_succeeded():
	Log.INFO("connection to masterserver success")
	#fetch_player_inventory()
	
func _on_connection_failed():
	Log.INFO("connection to masterserver fail")

func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())

remote func return_server_time(serverTime, clientTime):
	latency = (OS.get_system_time_msecs() - clientTime) / 2
	clientClock = serverTime + latency

remote func return_latency(clientTime):
	latencyArray.append((OS.get_system_time_msecs() - clientTime) / 2)
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

remote func fetch_token():
	print("returning token")
	rpc_id(1, "return_token", token)

remote func return_token_verification_results(result):
	if result == true:
		get_node("/root/Main/LoginScreen").queue_free()
		get_node("/root/Main").player_verified()
		print("successful token verification")
		GameServer.connect_to_server("127.0.0.1", 1908)
		#self.custom_multiplayer.set_root_node(server);
	else:
		print("login failed; try again")
		get_node("MainScreen/NinePatchRect/VBoxContainer/LoginButton").disabled = false

#lobby calls
func create_lobby():
	rpc_id(1, "request_create_lobby")

remote func lobby_created(playerId, lobbyId):
	get_node("/root/Main").load_lobby("Create")
	
func join_lobby(lobbyId):
	rpc_id(1, "request_join_lobby", lobbyId)
	
remote func return_lobby_joined(playerId, lobbyId):
	get_node("/root/Main/Hub").join_lobby()
	pass
	
func leave_lobby(lobbyId):
	rpc_id(1, "request_leave_lobby", lobbyId)

remote func return_lobby_left():
	get_node("/root/Main/Lobby").switch_to_hub()
	pass

func request_start_game(lobbyId):
	rpc_id(1, "request_start_game", lobbyId)
	
remote func game_starting():
	pass
	
remote func start_game():
	pass
	
