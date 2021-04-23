extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var port = 1910
const MAX_PLAYERS = 100

func _ready():
	start_server()
	
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func start_server():
	network.create_server(port, MAX_PLAYERS)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("gateway Server started!")
	
	network.connect("peer_connected", self, "_on_peer_connected")
	network.connect("peer_disconnected", self, "_on_peer_disconnected")
	
func _on_peer_connected(playerId):
	print("peer connected")
	
func _on_peer_disconnected(playerId):
	print("peer disconnected")
	
remote func login_request(username, password):
	print("Login request recieved")
	var playerId = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authenticate_player(username, password, playerId)
	
func return_login_request(result, playerId):
	rpc_id(playerId, "return_login_request", result)
	network.disconnect_peer(playerId)
