extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911
onready var Gateway = get_node("../Gateway")

func _ready():
	connect_to_server()
	
func connect_to_server():
	Log.DEBUG("client to authentication started!")
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")

func _on_connection_succeeded():
	Log.INFO("connection success")
	
func _on_connection_failed():
	Log.ERROR("connection fail. Have to restart")

func authenticate_player(username, password, playerId):
	Log.INFO("sending out auth request")
	rpc_id(1, "authenticate_player", username, password, playerId)
	
remote func authentication_results(result, playerId, token):
	Log.INFO("results received and replying to player login request")
	Gateway.return_login_request(result, playerId, token)

func create_account(username, password, playerId):
	Log.INFO("sending createAccount request")
	rpc_id(1, "create_account", username, password, playerId)
	
remote func return_create_account(result, playerId, message):
	Log.INFO("results received and replying to player create account request")
	Gateway.return_create_account_request(result, playerId, message)
