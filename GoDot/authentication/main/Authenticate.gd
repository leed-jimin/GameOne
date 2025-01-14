extends Node

var network = ENetMultiplayerPeer.new()
var port = 1911
const MAX_SERVERS = 5
#port 600
func _ready():
	start_server()

func start_server():
	network.create_server(port, MAX_SERVERS)
	multiplayer.set_multiplayer_peer(network)
	Logger.DEBUG("Server started!!!")
	
	network.connect("peer_connected", Callable(self, "_peer_connected"))
	network.connect("peer_disconnected", Callable(self, "_peer_disconnected"))

func _peer_connected(gatewayId):
	Logger.INFO("gateway connected Id: " + str(gatewayId))

func _peer_disconnected(gatewayId):
	Logger.INFO("gateway disconnected Id: " + str(gatewayId))

@rpc("any_peer")
func authenticate_player(username, password, playerId):
	var gatewayId = get_tree().get_remote_sender_id()
	var hashedPassword
	var result
	var token
	
	if not Database.PlayerIDs.has(username):
		result = false
	else:
		var retrievedSalt = Database.PlayerIDs[username].Salt
		hashedPassword = generate_hashed_password(password, retrievedSalt)
		
		if not Database.PlayerIDs[username].Password == hashedPassword:
			result = false
		else:
			result = true
			
			randomize()
			var hashed = str(randi()).sha256_text()
			var timestamp = str(Time.get_unix_time_from_system())
			token = hashed + timestamp
			var gameServer = GameServers.gameServerList[0] #have to load balance in the future
			GameServers.distribute_login_token(token, gameServer)# master server
			Logger.INFO("Successful Authentication for: " + String(playerId))

	rpc_id(gatewayId, "authentication_results", result, playerId, token)

#will need to change to read from server database
@rpc("any_peer")
func authenticate_server(username, password, serverId):
	var gatewayId = get_tree().get_remote_sender_id()
	var hashedPassword
	var result
	var token
	
	if not Database.ServerIDs.has(username):
		result = false
	else:
		var retrievedSalt = Database.ServerIDs[username].Salt
		hashedPassword = generate_hashed_password(password, retrievedSalt)
		
		if not Database.ServerIDs[username].Password == hashedPassword:
			result = false
		else:
			result = true
			
			randomize()
			var hashed = str(randi()).sha256_text()
			var timestamp = str(Time.get_unix_time_from_system())
			token = hashed + timestamp
			var gameServer = GameServers.gameServerList[0] #have to load balance in the future
			GameServers.distribute_login_token(token, gameServer) # master server
			Logger.INFO("Successful Authentication for: " + String(serverId))

	rpc_id(gatewayId, "authentication_results", result, serverId, token)

@rpc("any_peer")
func create_account(username, password, playerId):
	var gatewayId = get_tree().get_remote_sender_id()
	var result
	var message
	
	if Database.PlayerIDs.has(username):
		Logger.WARN("username exists")
		result = false
		message = 2
	else:
		Logger.INFO("saving username")
		result = true
		message = 3
		var salt = generate_salt()
		var hashedPassword = generate_hashed_password(password, salt)
		Database.PlayerIDs[username] = {"Password": hashedPassword, "Salt": salt}
		Database.SavePlayerIDs()
		
	rpc_id(gatewayId, "return_create_account", result, playerId, message)

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func generate_hashed_password(password, salt):
	var hashedPassword = password
	var rounds = pow(2, 3) #maybe increase later to 18
	while rounds > 0:
		hashedPassword = (hashedPassword + salt).sha256_text()
		rounds -= 1
	
	return hashedPassword
