extends Node

var network = ENetMultiplayerPeer.new()
var gatewayApi = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1912

@onready var MasterServer = get_node("/root/MasterServer")

func _ready():
	connect_to_server()
	
func _process(delta):
	if multiplayer == null:
		return
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()

func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_multiplayer(gatewayApi, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	Logger.DEBUG("GameServerHubConnection started!")
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	Logger.INFO("GameServerHubConnection success")
	
func _on_connection_failed():
	Logger.INFO("GameServerHubConnection fail")

@rpc("any_peer") func receive_login_token(token):
	Logger.DEBUG("login token received from auth")
	MasterServer.expectedTokens.append(token)
