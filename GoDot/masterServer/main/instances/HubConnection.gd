extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912

onready var MasterServer = get_node("/root/MasterServer")

func _ready():
	connect_to_server()
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server():
	network.create_client(ip, port)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Log.DEBUG("GameServerHubConnection started!")
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")

func _on_connection_succeeded():
	Log.INFO("GameServerHubConnection success")
	
func _on_connection_failed():
	Log.INFO("GameServerHubConnection fail")

remote func receive_login_token(token):
	Log.DEBUG("login token received from auth")
	MasterServer.expectedTokens.append(token)
