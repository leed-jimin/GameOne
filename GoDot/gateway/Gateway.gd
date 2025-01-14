extends Node

var network = ENetMultiplayerPeer.new()
var gatewayApi = SceneMultiplayer.new()
var port = 1910
const MAX_PLAYERS = 100
var test = 0
var cert = load("res://certificate/x509_Certificate.crt")
var key = load("res://certificate/x509_Key.key")

func _ready():
	start_server()
	
func _process(delta):
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()
	
func start_server():
	#network.set_dtls_enabled(true)
	#network.set_dtls_key(key)
	#network.set_dtls_certificate(cert)
	network.create_server(port, MAX_PLAYERS)
	get_tree().set_multiplayer(gatewayApi, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	print("gateway server started!")
	
	network.connect("peer_connected", Callable(self, "_on_peer_connected"))
	network.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	
func _on_peer_connected(playerId):
	Logger.INFO("peer connected: " + str(playerId))
	
func _on_peer_disconnected(playerId):
	Logger.INFO("peer disconnected: " + str(playerId))
	
@rpc("any_peer")
func login_request(username, password, isServer = false):
	Logger.INFO("login request recieved")
	var playerId = multiplayer.get_remote_sender_id()
	if isServer:
		Authenticate.authenticate_server(username, password, playerId)
	else:
		Authenticate.authenticate_player(username, password, playerId)
	
func return_login_request(result, playerId, token):
	rpc_id(playerId, "return_login_request", result, token)
	network.disconnect_peer(playerId)

@rpc("any_peer")
func create_account_request(username, password):
	Logger.DEBUG("create account request received")
	var playerId = multiplayer.get_remote_sender_id()
	var valid = true
	if username == null:
		Logger.ERROR("Please provide a valid username.")
		valid = false
	if password == null:
		Logger.ERROR("Please provide a valid password.")
		valid = false
	#need extra handling
	if valid:
		Authenticate.create_account(username.to_lower(), password, playerId)
	else:
		return_create_account_request(valid, playerId, 1)
	
func return_create_account_request(result, playerId, message):
	rpc_id(playerId, "return_create_account_request", result, message)
	# 1 = failed, 2 = existing username, 3 = good
	network.disconnect_peer(playerId)
