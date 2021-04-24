extends Node

onready var playerVerificationProcess = get_node("PlayerVerification")
onready var combatFunctions = get_node("Combat")

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
	playerVerificationProcess.start(playerId)
	
	
func _peer_disconnected(playerId):
	print("disconnected Id: " + String(playerId))
	get_node(str(playerId)).queue_free()

remote func fetch_player_inventory():
	var playerId = get_tree().get_rpc_sender_id()
	var playerInventory = get_node(str(playerId)).playerInventory
	rpc_id(playerId, "return_player_inventory", playerInventory)
