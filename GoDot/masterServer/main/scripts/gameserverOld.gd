extends Node

onready var playerVerificationProcess = get_node("PlayerVerification")

var masterNetwork = NetworkedMultiplayerENet.new()
var masterNetworkPort = 1909

var subNetwork = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var subNetworkPort = 1908
var ip = "127.0.0.1"
const MAX_PLAYERS = 10

var expectedTokens = []

func _ready():
	connect_to_server()

func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server():
	masterNetwork.create_client(ip, masterNetworkPort)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(masterNetwork)
	print("Connecting to master")
	
	masterNetwork.connect("connection_succeeded", self, "_on_connection_succeeded")
	masterNetwork.connect("connection_failed", self, "_on_connection_failed")
	
	#start_server()

func _on_connection_succeeded():
	print("connection success")
	
func _on_connection_failed():
	print("connection fail")
	

func start_server():
	subNetwork.create_server(subNetworkPort, MAX_PLAYERS)
	get_tree().set_network_peer(subNetwork)
	print("Server started!")
	
	subNetwork.connect("peer_connected", self, "_peer_connected")
	subNetwork.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(playerId):
	print("connected Id: " + String(playerId))
	playerVerificationProcess.start(playerId)
	
func _peer_disconnected(playerId):
	print("disconnected Id: " + String(playerId))
	if has_node(str(playerId)):
		get_node(str(playerId)).queue_free()
		#playerStateCollection.erase(playerId)
		#get_node("GameLogic").playerList.erase(playerId)
		#rpc_id(0, "despawn_player", playerId)

#movement
remote func receive_player_state(playerState):
	pass
#	var playerId = get_tree().get_rpc_sender_id()
#	if playerStateCollection.has(playerId):
#		if playerStateCollection[playerId]["T"] < playerState["T"]:
#			playerStateCollection[playerId] = playerState
#	else:
#		playerStateCollection[playerId] = playerState
		
func send_world_state(worldState):
	rpc_unreliable_id(0, "receive_world_state", worldState)
	
#Combat rpc calls
func send_receive_hit(playerId, damage):
	print("sending receive hit")
	rpc_id(0, "receive_hit", playerId, damage)

remote func character_hit(receiverId, attackPosition, receiverPosition): #damage?
	var playerId = get_tree().get_rpc_sender_id()
	#GameLogic.character_hit(receiverId, attackPosition, receiverPosition)

remote func attack(attack, clientClock):
	var playerId = get_tree().get_rpc_sender_id()
	rpc_id(0, "receive_attack", attack, clientClock, playerId)
