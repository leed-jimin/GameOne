extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var port = 1910
const MAX_PLAYERS = 100

var cert = load("res://certificate/x509_Certificate.crt")
var key = load("res://certificate/x509_Key.key")

func _ready():
	start_server()
	
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func start_server():
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, MAX_PLAYERS)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Log.DEBUG("gateway server started!")
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")
	
func _on_peer_connected(playerId):
	Log.INFO("peer connected: " + str(playerId))
	
func _on_peer_disconnected(playerId):
	Log.INFO("peer disconnected: " + str(playerId))
	
remote func login_request(username, password):
	Log.INFO("login request recieved")
	var playerId = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authenticate_player(username, password, playerId)
	
func return_login_request(result, playerId, token):
	rpc_id(playerId, "return_login_request", result, token)
	network.disconnect_peer(playerId)

remote func create_account_request(username, password):
	Log.DEBUG("create account request received")
	var playerId = custom_multiplayer.get_rpc_sender_id()
	var valid = true
	if username == null:
		Log.ERROR("Please provide a valid username.")
		valid = false
	if password == null:
		Log.ERROR("Please provide a valid password.")
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
