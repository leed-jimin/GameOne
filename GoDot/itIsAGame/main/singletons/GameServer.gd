extends Node

var network = ENetMultiplayerPeer.new()

var clientClock = 0
var decimalCollector : float = 0
var latencyArray = []
var latency = 0
var deltaLatency = 0

	
func _physics_process(delta):
	clientClock += int(delta * 1000) + deltaLatency
	deltaLatency = 0
	decimalCollector += (delta * 1000) - int(delta * 1000)
	if decimalCollector >= 1.00:
		clientClock += 1
		decimalCollector -= 1.00

func connect_to_server(ip, port):
	#get_tree().network_peer = null
	network.create_client(ip, int(port))
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	Log.INFO("GameServer connection success")
	rpc_id(1, "fetch_server_time", Time.get_ticks_msec())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", Callable(self, "determine_latency"))
	self.add_child(timer)
	
func _on_connection_failed():
	Log.INFO("GameServer connection fail")

func determine_latency():
	rpc_id(1, "determine_latency", Time.get_ticks_msec())
	
@rpc
func return_server_time(serverTime, clientTime):
	latency = (Time.get_unix_time_from_system() - clientTime) / 2
	clientClock = serverTime + latency

@rpc
func return_latency(clientTime):
	latencyArray.append((Time.get_unix_time_from_system() - clientTime) / 2)
	if latencyArray.size() == 9:
		var totalLatency = 0
		latencyArray.sort()
		var midPoint = latencyArray[4]
		for i in range(latencyArray.size() - 1, -1, -1):
			if latencyArray[i] > (2 * midPoint) and latencyArray[i] > 20:
				latencyArray.remove(i)
			else:
				totalLatency += latencyArray[i]
		deltaLatency = (totalLatency / latencyArray.size()) - latency
		latency = totalLatency / latencyArray.size()
		print("new latency", latency)
		latencyArray.clear()

@rpc("unreliable")
func send_player_state(playerState):
	rpc_id(1, "receive_player_state", playerState)

@rpc
func receive_world_state(worldState):
	get_node("/root/Main/SceneHandler").update_world_state(worldState)

@rpc
func spawn_new_player(playerId, spawnPosition):
	get_node("/root/Main/SceneHandler").spawn_new_player(playerId, spawnPosition)

@rpc
func despawn_player(playerId):
	get_node("/root/Main/SceneHandler").despawn_player(playerId)

@rpc
func send_attack(attack):
	rpc_id(1, "attack", attack, clientClock)

@rpc
func receive_attack(spawnTime, playerId, attack, damage):
	if playerId == get_tree().get_network_unique_id():
		pass  # Could correct client-side predictions
	else:
		get_node("/root/Main/SceneHandler/YSort/OtherPlayers/" + str(playerId)).actionDict[spawnTime] = attack

@rpc
func send_character_hit(id, attackPosition, attackeePosition):
	rpc_id(1, "character_hit", id, attackPosition, attackeePosition)

@rpc
func receive_hit(playerId, damage):
	print("receiving hit")
	if playerId == get_tree().get_network_unique_id():
		print("got hit")
		get_node("/root/Main/SceneHandler/characterModel/AnimationHandler").on_hit(damage)
	else:
		print("other got hit")
		get_node("/root/Main/SceneHandler/YSort/OtherPlayers/" + str(playerId)).on_hit(damage)

# Server calls for player info
@rpc
func fetch_player_inventory():
	rpc_id(1, "fetch_player_inventory")
