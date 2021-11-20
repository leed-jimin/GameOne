extends Node

onready var PlayerContainer = preload("res://main/PlayerContainer/PlayerContainer.tscn") # Relative path

var network = NetworkedMultiplayerENet.new()
var port = 1908
const MAX_PLAYERS = 100

var clientClock = 0
var decimalCollector : float = 0
var latencyArray = []
var latency = 0
var deltaLatency = 0

func _ready():
#	Gateway.connect_to_server("server1", "server1", false) # for testing
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
	get_tree().set_network_peer(network)
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	Log.DEBUG("game server started!")

func create_player_container(playerId):
	var newPlayerContainer = PlayerContainer.instance()
	newPlayerContainer.name = str(playerId)
	get_parent().add_child(newPlayerContainer, true)
	var playerContainer = get_node("../" + str(playerId))
	#fill_player_container(playerContainer)

func _peer_connected(clientId):
	Log.INFO("connected Id: " + String(clientId))
	create_player_container(clientId)
	
func _peer_disconnected(clientId):
	Log.INFO("disconnected Id: " + String(clientId))
	if has_node(str(clientId)):
		get_node(str(clientId)).queue_free()
		#playerStateCollection.erase(playerId)
		#get_node("GameLogic").playerList.erase(playerId)
		#rpc_id(0, "despawn_player", playerId)

remote func return_server_time(serverTime, clientTime):
	latency = (OS.get_system_time_msecs() - clientTime) / 2
	clientClock = serverTime + latency

remote func return_latency(clientTime):
	latencyArray.append((OS.get_system_time_msecs() - clientTime) / 2)
	if latencyArray.size() == 9:
		var totalLatency = 0
		latencyArray.sort()
		var midPoint = latencyArray[4]
		for i in range(latencyArray.size()-1,-1,-1):
			if latencyArray[i] > (2 * midPoint) and latencyArray[i] > 20:
				latencyArray.remove(i)
			else:
				totalLatency += latencyArray[i]
		deltaLatency = (totalLatency / latencyArray.size()) - latency
		latency = totalLatency / latencyArray.size()
		#print("new latency", latency)
		latencyArray.clear()

remote func start_game():
	pass
	
#Combat rpc calls
#func npc_hit(enemyId, damage):
#	rpc_id(1, "send_npc_hit", enemyId, damage)
#
#func player_hit(playerId, damage):
#	rpc_id(1, "send_player_hit", playerId, damage)
#
func send_attack(attack):
	rpc_id(1, "attack", attack, clientClock)

func send_character_hit(id, attackPosition, attackeePosition):
	rpc_id(1, "character_hit", id, attackPosition, attackeePosition)
	
remote func receive_attack(attack, spawnTime, playerId):
	if playerId == get_tree().get_network_unique_id():
		pass #could correct client side predictions
	else:
		get_node("/root/SceneHandler/YSort/OtherPlayers/" + str(playerId)).attackDict[spawnTime] = {"Attack": attack}
	
remote func receive_hit(playerId, damage):
	print("receiving hit")
	if playerId == get_tree().get_network_unique_id():
		print("got hit")
		get_node("/root/SceneHandler/characterModel/AnimationHandler").on_hit(damage)
	else:
		print("other got hit")
		get_node("/root/SceneHandler/YSort/OtherPlayers/" + str(playerId)).on_hit(damage);

func send_player_state(playerState):
	rpc_unreliable_id(1, "receive_player_state", playerState)

remote func receive_world_state(worldState):
	get_node("/root/SceneHandler").update_world_state(worldState)

remote func spawn_new_player(playerId, spawnPosition):
	get_node("/root/SceneHandler").spawn_new_player(playerId, spawnPosition)
	
remote func despawn_player(playerId):
	get_node("/root/SceneHandler").despawn_player(playerId)

func request_start_game(lobbyId):
	rpc_id(1, "request_start_game", lobbyId)
	
remote func game_starting():
	pass
	
	
#Combat rpc calls
#func npc_hit(enemyId, damage):
#	rpc_id(1, "send_npc_hit", enemyId, damage)
#
#func player_hit(playerId, damage):
#	rpc_id(1, "send_player_hit", playerId, damage)
#
