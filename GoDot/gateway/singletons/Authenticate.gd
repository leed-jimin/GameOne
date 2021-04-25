extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911


func _ready():
	connect_to_server()
	
func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("auth Server started!")
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	

func _on_connection_succeeded():
	print("connection success")
	
func _on_connection_failed():
	print("connection fail")

func authenticate_player(username, password, playerId):
	print("sending out auth request")
	rpc_id(1, "authenticate_player", username, password, playerId)
	
remote func authentication_results(result, playerId, token):
	print("results received and replying to player login request")
	Gateway.return_login_request(result, playerId, token)
