extends Node

var network = ENetMultiplayerPeer.new()
var gatewayApi = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://resources/certificate/x509_Certificate.crt")
@onready var GameServer = get_node("/root/GameServer")

var username
var password
var newAccount = false

func _ready():
	pass
	
func _process(delta):
	if multiplayer == null:
		return
	if not multiplayer.has_multiplayer_peer():
		return
	multiplayer.poll()
	
func connect_to_server(_username, _password, _newAccount):
	network = ENetMultiplayerPeer.new()
	gatewayApi = SceneMultiplayer.new()
	#network.set_dtls_enabled(true)
	#network.set_dtls_verify_enabled(false) #set to true when using signed certificate
	#network.set_dtls_certificate(cert)
	username = _username
	password = _password
	newAccount = _newAccount
	network.create_client(ip, port)
	get_tree().set_multiplayer(gatewayApi, self.get_path())
	multiplayer.set_multiplayer_peer(network)
	Logger.DEBUG("Attempting to connect to gateway")
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	print("connection success")
	request_login()
	
func _on_connection_failed():
	print("connection fail")
	#reenable everything

func request_login():
	rpc_id(1, "login_request")
	#rpc_id(1, "login_request", username, password.sha256_text(), true)
	username = ""
	password = ""

@rpc("any_peer") 
func return_login_request(results, token):
	if results == true:
		GameServer.start_server()
		MasterServer.token = token
		MasterServer.connect_to_server()
	else:
		print("Please provide correct username and password")
		#any other handling
	network.disconnect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.disconnect("connection_failed", Callable(self, "_on_connection_failed"))
