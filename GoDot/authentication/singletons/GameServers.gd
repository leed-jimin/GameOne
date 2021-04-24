extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var port = 1912
const MAX_PLAYERS = 100

var gameServerList = {}


func _ready():
	start_server()
	
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	set_custom_multiplayer(network)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(gameServerId):
	print("gameServer connected: " + str(gameServerId))
	gameServerList["GameServer1"] = gameServerId
	print(gameServerList)
	
func _peer_disconnected(gameServerId):
	print("gameServer disconnected: " + str(gameServerId))
