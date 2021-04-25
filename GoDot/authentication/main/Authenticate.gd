extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
const MAX_SERVERS = 5


func _ready():
	start_server()
	
func start_server():
	network.create_server(port, MAX_SERVERS)
	get_tree().set_network_peer(network)
	print("Auth server started!")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	

func _peer_connected(gatewayId):
	print("gateway connected Id: " + String(gatewayId))
	
func _peer_disconnected(gatewayId):
	print("gateway disconnected Id: " + String(gatewayId))

remote func authenticate_player(username, password, playerId):
	var gatewayId = get_tree().get_rpc_sender_id()
	var result
	var token
	
	if not PlayerData.PlayerIDs.has(username):
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		result = false
	else:
		print("Successful Authentication")
		result = true
		
		randomize()
		var hashed = str(randi()).sha256_text()
		var timestamp = str(OS.get_unix_time())
		print(timestamp)
		token = hashed + timestamp
		print(token)
		var gameServer = "GameServer1" #have to load balance in the future
		GameServers.distribute_login_token(token, gameServer)

	rpc_id(gatewayId, "authentication_results", result, playerId, token)
