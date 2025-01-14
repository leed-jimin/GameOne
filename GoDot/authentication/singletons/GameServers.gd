extends Node

var network = ENetMultiplayerPeer.new()
var gatewayApi = SceneMultiplayer.new()
var port = 1912
const MAX_PLAYERS = 10
var gameServerList = []


func _ready():
	start_server()
	
func _process(_delta):
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_multiplayer(gatewayApi, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	Logger.DEBUG("GameServerHub started")
	
	network.connect("peer_connected", Callable(self, "_peer_connected"))
	network.connect("peer_disconnected", Callable(self, "_peer_disconnected"))
	
func _peer_connected(gameServerId):
	Logger.INFO("gameServer connected: " + str(gameServerId))
	gameServerList.append(gameServerId)
	Logger.DEBUG(gameServerList)
	
func _peer_disconnected(gameServerId):
	Logger.INFO("gameServer disconnected: " + str(gameServerId))
	gameServerList.erase(gameServerId)

func distribute_login_token(token, gameServer):
	var gameServerPeerId = gameServerList[0]
	rpc_id(gameServerPeerId, "receive_login_token", token)
