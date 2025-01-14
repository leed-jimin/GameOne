extends Node

@onready var PlayerContainer = preload("res://main/PlayerContainer/PlayerContainer.tscn") # Relative path

var network = ENetMultiplayerPeer.new()
var port = 1908
const MAX_PLAYERS = 100

var clientClock = 0
var decimalCollector : float = 0
var latencyArray = []
var latency = 0
var deltaLatency = 0


func _ready():
	#Gateway.connect_to_server("server1", "server1", false) # for testing
	start_server()
	
func _physics_process(delta):
	clientClock += int(delta * 1000) + deltaLatency
	deltaLatency = 0
	decimalCollector += (delta * 1000) - int(delta * 1000)
	if decimalCollector >= 1.00:
		clientClock += 1
		decimalCollector -= 1.00

func start_server():
	network.create_server(port, MAX_PLAYERS)
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("peer_connected", Callable(self, "_peer_connected"))
	network.connect("peer_disconnected", Callable(self, "_peer_disconnected"))
	Logger.DEBUG("game server started!")

func create_player_container(playerId):
	var newPlayerContainer = PlayerContainer.instantiate()
	newPlayerContainer.name = str(playerId)
	add_child(newPlayerContainer, true)
	#var playerContainer = get_node(str(playerId))
	#fill_player_container(playerContainer)

func _peer_connected(playerId):
	Logger.INFO("connected Id: " + String(playerId))
	create_player_container(playerId)
	
func _peer_disconnected(playerId):
	Logger.INFO("disconnected Id: " + String(playerId))
	if has_node(str(playerId)):
		get_node(str(playerId)).queue_free()
		StateProcessing.playerStateCollection.erase(playerId)
		StateProcessing.playerList.erase(playerId)
		rpc_id(0, "despawn_player", playerId)

@rpc("any_peer") 
func fetch_server_time(clientTime):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_server_time", Time.get_ticks_msec(), clientTime)
	
@rpc("any_peer") 
func determine_latency(clientTime):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(playerId, "return_latency", clientTime)

@rpc("any_peer") 
func receive_player_state(playerState):
	var playerId = get_tree().get_remote_sender_id()
	var collection = StateProcessing.playerStateCollection
	if collection.has(playerId):
		if collection[playerId]["T"] < playerState["T"]:
			collection[playerId] = playerState
	else:
		collection[playerId] = playerState

@rpc("any_peer", "unreliable") 
func send_world_state(worldState):
	rpc_id(0, "receive_world_state", worldState)

@rpc("any_peer") 
func start_game():
	pass

@rpc("any_peer") 
func game_starting():
	pass
	
#Combat rpc calls
func player_hit(playerId, damage):
	rpc_id(0, "send_player_hit", playerId, damage)

@rpc("any_peer") 
func attack(attack, clientClock):
	var playerId = get_tree().get_remote_sender_id()
	rpc_id(0, "receive_attack", clientClock, playerId, attack, 10)
