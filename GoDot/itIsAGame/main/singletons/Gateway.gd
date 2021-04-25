extends Node

var network = NetworkedMultiplayerENet.new()
var gatewayApi = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910

var username
var password

func _ready():
	pass
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func connect_to_server(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gatewayApi = MultiplayerAPI.new()
	username = _username
	password = _password
	
	network.create_client(ip, port)
	set_custom_multiplayer(gatewayApi)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")

func _on_connection_succeeded():
	print("connection success")
	request_login()
	
func _on_connection_failed():
	print("connection fail")
	get_node("/root/SceneHandler/LoginScreen/NinePatchRect/VBoxContainer/LoginButton").disabled = false

func request_login():
	print("Request to connect to gateway")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""

remote func return_login_request(results, token):
	print("results received")
	if results == true:
		Server.token = token
		print(token)
		Server.connect_to_server()
		#remove gui for login
	else:
		print("Please provide correct username and password")
		get_node("/root/SceneHandler/LoginScreen/NinePatchRect/VBoxContainer/LoginButton").disabled = false
		#any other handling
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
	network.disconnect("connection_failed", self, "_on_connection_failed")
