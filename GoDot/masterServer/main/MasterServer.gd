extends Node

@onready var playerVerificationProcess = get_node("PlayerVerification")

var network = ENetMultiplayerPeer.new()
var port = 1909
const MAX_PLAYERS = 100
var serverCount = 0
var gameServerList = {}

var expectedTokens = []

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	multiplayer.set_multiplayer_peer(network)
	Logger.DEBUG("master server started!")
	
	network.connect("peer_connected", Callable(self, "_peer_connected"))
	network.connect("peer_disconnected", Callable(self, "_peer_disconnected"))


func _peer_connected(clientId):
	print("connected Id: " + String(clientId))
	playerVerificationProcess.start(clientId)
	
func _peer_disconnected(clientId):
	print("disconnected Id: " + String(clientId))
	if has_node(str(clientId)):
		get_node(str(clientId)).queue_free()
		#playerStateCollection.erase(playerId)
		#get_node("GameLogic").playerList.erase(playerId)
		#rpc_id(0, "despawn_player", playerId)

func _on_TokenExpiration_timeout():
	var currentTime = Time.get_unix_time_from_system()
	var tokenTime
	if not expectedTokens == []:
		for i in range(expectedTokens.size() - 1, -1, -1):
			tokenTime = int(expectedTokens[i].right(64))
			if currentTime - tokenTime >= 30:
				expectedTokens.remove(i)
				
	print("Expected Tokens: ")
	print(expectedTokens)
	
@rpc("any_peer") func connect_as_server():
	var serverId = get_tree().get_remote_sender_id()
	gameServerList[serverId] = { "gameSessions": 0 }
	
func fetch_token(playerId):
	Logger.DEBUG("Fetching token from: " + str(playerId))
	rpc_id(playerId, "fetch_token")
	
@rpc("any_peer") func return_token(token):
	Logger.DEBUG("received token, starting verification")
	var playerId = get_tree().get_remote_sender_id()
	playerVerificationProcess.verify(playerId, token)

func return_token_verification_results(playerId, result):
	Logger.DEBUG("token results received")
	rpc_id(playerId, "return_token_verification_results", result)
#	if result == true:
#		rpc_id(0, "spawn_new_player", playerId, Vector3(0, 20, 0))
	
@rpc("any_peer") func fetch_server_time(clientTime):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_server_time", Time.get_ticks_msec(), clientTime)
	
@rpc("any_peer") func determine_latency(clientTime):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_latency", clientTime)

#Lobby calls
@rpc("any_peer") func request_create_lobby():
	var playerId = get_tree().get_remote_sender_id()
	LobbyHandler.create_lobby(playerId)
	
func lobby_created(lobbyId):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(0, "lobby_created", playerId, lobbyId)
	
@rpc("any_peer") func request_join_lobby(playerId, lobbyId):
	LobbyHandler.join_lobby(playerId, lobbyId)
	
func lobby_joined(lobbyId):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_lobby_joined", playerId, lobbyId)
	
@rpc("any_peer") func request_leave_lobby(lobbyId):
	var playerId = get_tree().get_remote_sender_id()
	LobbyHandler.leave_lobby(playerId, lobbyId)
	
func lobby_left():
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_lobby_left")

@rpc("any_peer") func request_start_game(lobbyId):
	LobbyHandler.start_game(lobbyId)
	
func game_starting(playerId, ip, port):
	rpc_id(playerId, "connect_to_game", "127.0.0.1", "1908")
