extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var port = 1912
const MAX_PLAYERS = 10
var gameServerList = []


func _ready():
	start_server()
	
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Log.DEBUG("GameServerHub started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(gameServerId):
	Log.INFO("gameServer connected: " + str(gameServerId))
	gameServerList.append(gameServerId) 
	Log.DEBUG(gameServerList)
	
func _peer_disconnected(gameServerId):
	Log.INFO("gameServer disconnected: " + str(gameServerId))
	gameServerList.erase(gameServerId)

func distribute_login_token(token, gameServer):
	var gameServerPeerId = gameServerList[0]
	rpc_id(gameServerPeerId, "receive_login_token", token)
