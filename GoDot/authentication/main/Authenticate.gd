extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
const MAX_SERVERS = 5


func _ready():
	start_server()
	
func start_server():
	network.create_server(port, MAX_SERVERS)
	get_tree().set_network_peer(network)
	print("AU:Auth server started!")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	

func _peer_connected(gatewayId):
	print("AU:gateway connected Id: " + String(gatewayId))
	
func _peer_disconnected(gatewayId):
	print("AU:gateway disconnected Id: " + String(gatewayId))

remote func authenticate_player(username, password, playerId):
	var gatewayId = get_tree().get_rpc_sender_id()
	var hashedPassword
	var result
	var token
	
	if not PlayerData.PlayerIDs.has(username):
		result = false
	else:
		var retrievedSalt = PlayerData.PlayerIDs[username].Salt
		hashedPassword = generate_hashed_password(password, retrievedSalt)
		
		if not PlayerData.PlayerIDs[username].Password == hashedPassword:
			result = false
		else:
			print("AU:Successful Authentication")
			result = true
			
			randomize()
			var hashed = str(randi()).sha256_text()
			var timestamp = str(OS.get_unix_time())
			token = hashed + timestamp
			var gameServer = "GameServer" + str(GameServers.serverCount - 1) #have to load balance in the future
			GameServers.distribute_login_token(token, gameServer)

	rpc_id(gatewayId, "authentication_results", result, playerId, token)

remote func create_account(username, password, playerId):
	var gatewayId = get_tree().get_rpc_sender_id()
	var result
	var message
	
	if PlayerData.PlayerIDs.has(username):
		print("AU:username exists")
		result = false
		message = 2
	else:
		print("AU:saving username")
		result = true
		message = 3
		var salt = generate_salt()
		var hashedPassword = generate_hashed_password(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashedPassword, "Salt": salt}
		PlayerData.SavePlayerIDs()
		
	rpc_id(gatewayId, "return_create_account", result, playerId, message)

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("AU:salt:" + salt)
	return salt

func generate_hashed_password(password, salt):
	var hashedPassword = password
	var rounds = pow(2, 3) #maybe increase later to 18
	print(hashedPassword)
	while rounds > 0:
		hashedPassword = (hashedPassword + salt).sha256_text()
		rounds -= 1
	print("newhashed:" + hashedPassword)
	
	return hashedPassword
