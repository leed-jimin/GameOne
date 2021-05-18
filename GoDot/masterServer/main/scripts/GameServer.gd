extends Node

onready var stateProcessing = load("res://main/scenes/StateProcessing.tscn")

var subNetwork = NetworkedMultiplayerENet.new()
var subNetworkPort = 1908
const MAX_PLAYERS = 10

var playerDict = {}

func _ready():
	start_server()
	#add_child(stateProcessing.instance())

func start_server():
	subNetwork.create_server(subNetworkPort, MAX_PLAYERS)
	get_tree().set_network_peer(subNetwork)
	print("Server started!")
	
	subNetwork.connect("peer_connected", self, "_peer_connected")
	subNetwork.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(playerId):
	print("connected Id: " + String(playerId))
	
func _peer_disconnected(playerId):
	print("disconnected Id: " + String(playerId))
	if has_node(str(playerId)):
		get_node(str(playerId)).queue_free()
		get_node("StateProcessing").playerStateCollection.erase(playerId)
		get_node("GameLogic").playerList.erase(playerId)
		rpc_id(0, "despawn_player", playerId)

#movement
remote func receive_player_state(playerState):
	var playerId = get_tree().get_rpc_sender_id()
	var collection = get_node("StateProcessing").playerStateCollection
	if collection.has(playerId):
		if collection[playerId]["T"] < playerState["T"]:
			collection[playerId] = playerState
	else:
		collection[playerId] = playerState
		
func send_world_state(worldState):
	rpc_unreliable_id(0, "receive_world_state", worldState)
	
#Combat rpc calls
func send_receive_hit(playerId, damage):
	print("sending receive hit")
	rpc_id(0, "receive_hit", playerId, damage)

remote func character_hit(receiverId, attackPosition, receiverPosition): #damage?
	var playerId = get_tree().get_rpc_sender_id()
	get_node("StateProcessing").character_hit(receiverId, attackPosition, receiverPosition)

remote func attack(attack, clientClock):
	var playerId = get_tree().get_rpc_sender_id()
	rpc_id(0, "receive_attack", attack, clientClock, playerId)
