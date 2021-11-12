extends Node

onready var playerVerificationProcess = get_node("PlayerVerification")

var network = NetworkedMultiplayerENet.new()
var port = 1908
const MAX_PLAYERS = 100
var serverCount = 0
var gameServerList = {}

var expectedTokens = []

func _ready():
	Gateway.connect_to_server("server1", "test1", false) # for testing
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	Log.DEBUG("master server started!")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

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
