extends Node

onready var loginScreen = load("res://GUI/scenes/LoginScreen.tscn")
onready var transition = load("res://GUI/scenes/Transition.tscn")
onready var hub = load("res://GUI/scenes/Hub.tscn")
onready var lobby = load("res://GUI/scenes/Lobby.tscn")
onready var sceneHandler = load("res://main//src/SceneHandler.tscn")

func _ready():
	#load_login_screen()
	#Gateway.connect_to_server("test1", "test1", false)
	GameServer.connect_to_server("127.0.0.1", 1908)
#	MasterServer.connect_to_server()
	load_game() #for testing animations

func load_login_screen():
	add_child(loginScreen.instance())
	
func player_verified():
	load_hub()

func load_hub():
	add_child(hub.instance())
	
func load_lobby(action):
	match action:
		"Join":
			pass
		"Create":
			pass
	add_child(lobby.instance())
	get_node("Hub").hide()
	
func load_game():
	add_child(sceneHandler.instance())
	
func transition():
	add_child(transition.instance())
	delete_children()
	
func delete_children():
	for n in get_children():
		if (n.name != "Transition"):
			remove_child(n)
			n.queue_free()
