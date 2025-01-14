extends Node

var network = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1911
@onready var Gateway = get_node("../Gateway")

func _ready():
	connect_to_server()
	
func connect_to_server():
	Logger.DEBUG("client to authentication started!")
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	Logger.INFO("connection success")
	
func _on_connection_failed():
	Logger.ERROR("connection fail. Have to restart")

func authenticate_player(username, password, playerId):
	Logger.INFO("sending out auth request")
	rpc_id(1, "authenticate_player", username, password, playerId)

func authenticate_server(username, password, playerId):
	Logger.INFO("sending out auth request for server")
	rpc_id(1, "authenticate_server", username, password, playerId)
	
@rpc("any_peer")
func authentication_results(result, playerId, token):
	Logger.INFO("results received and replying to player login request")
	Gateway.return_login_request(result, playerId, token)

func create_account(username, password, playerId):
	Logger.INFO("sending createAccount request")
	rpc_id(1, "create_account", username, password, playerId)
	
@rpc("any_peer")
func return_create_account(result, playerId, message):
	Logger.INFO("results received and replying to player create account request")
	Gateway.return_create_account_request(result, playerId, message)
