extends Node

onready var playerVerificationProcess = get_node("PlayerVerification")
onready var combatFunctions = get_node("Combat")

var network = NetworkedMultiplayerENet.new()
var port = 1909
const MAX_PLAYERS = 100

var expectedTokens = []

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	print("Server started!")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(playerId):
	print("connected Id: " + String(playerId))
	playerVerificationProcess.start(playerId)
	
func _peer_disconnected(playerId):
	print("disconnected Id: " + String(playerId))
	if has_node(str(playerId)):
		get_node(str(playerId)).queue_free()

func _on_TokenExpiration_timeout():
	var currentTime = OS.get_unix_time()
	var tokenTime
	if not expectedTokens == []:
		for i in range(expectedTokens.size() - 1, -1, -1):
			tokenTime = int(expectedTokens[i].right(64))
			if currentTime - tokenTime >= 30:
				expectedTokens.remove(i)
				
	print("Expected Tokens: ")
	print(expectedTokens)
	
func fetch_token(playerId):
	rpc_id(playerId, "fetch_token")
	
remote func return_token(token):
	var playerId = get_tree().get_rpc_sender_id()
	playerVerificationProcess.verify(playerId, token)

func return_token_verification_results(playerId, result):
	rpc_id(playerId, "return_token_verification_results", result)

#Game request values for players
remote func fetch_player_inventory():
	var playerId = get_tree().get_rpc_sender_id()
	var playerInventory = get_node(str(playerId)).playerInventory
	rpc_id(playerId, "return_player_inventory", playerInventory)

