extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
const MAX_PLAYERS = 108


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
	
func _peer_disconnected(playerId):
	print("disconnected Id: " + String(playerId))
