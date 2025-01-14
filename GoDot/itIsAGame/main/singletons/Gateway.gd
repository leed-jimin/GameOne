extends Node

var network = ENetMultiplayerPeer.new()
var gatewayApi = SceneMultiplayer.new()
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://resources/certificate/x509_Certificate.crt")

var username
var password
var newAccount = false

func _ready():
	pass
	
func _process(_delta):
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
	#multiplayer.set_root_node(self)
	multiplayer.set_multiplayer_peer(network)
	
	network.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.connect("connection_failed", Callable(self, "_on_connection_failed"))

func _on_connection_succeeded():
	if newAccount:
		request_create_account()
	else:
		request_login()
	
func _on_connection_failed():
	Log.INFO("gateway connection fail")
	get_node("/root/Main/LoginScreen/Background/Login/LoginButton").disabled = false
	#reenable everything

func request_login():
	print("Request to connect to gateway")
	rpc_id(1, "login_request", username, password.sha256_text())
	username = ""
	password = ""

@rpc("any_peer") func return_login_request(results, token):
	print("results received:" + str(results))
	if results == true:
		MasterServer.token = token
		MasterServer.connect_to_server()
	else:
		print("Please provide correct username and password")
		get_node("/root/Main/LoginScreen/Background/Login/LoginButton").disabled = false
		#any other handling
#	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
#	network.disconnect("connection_failed", self, "_on_connection_failed")

func request_create_account():
	print("Requesting new account")
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""
	
@rpc("any_peer") func return_create_account_request(results, message):
	print("results received")
	if results:
		print("Account created, logging in")
		#login user
	else:
		if message == 1:
			print("Couldn't create account, please try again.")
		elif message == 2:
			print("The username already exists, please use a different username.")
		get_node("../SceneHandler/MainScreen/Background/CreateAccount").SignUp.disabled = false
		get_node("../SceneHandler/MainScreen/Background/CreateAccount").Cancel.disabled = false
	
	network.disconnect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	network.disconnect("connection_failed", Callable(self, "_on_connection_failed"))
		
