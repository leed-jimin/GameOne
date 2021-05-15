extends Node

onready var loginScreen = load("res://GUI/scenes/LoginScreen.tscn")
onready var transition = load("res://GUI/scenes/Transition.tscn")
onready var hub = load("res://GUI/scenes/Hub.tscn")
onready var lobby = load("res://GUI/scenes/Lobby.tscn")
onready var game = load("res://main/SceneHandler.tscn")

func _ready():
	load_login_screen()
	pass

func load_login_screen():
	add_child(loginScreen.instance())
	pass
	
func player_verified():
	load_hub()

func load_hub():
	add_child(hub.instance())
	pass
	
func load_lobby(action):
	match action:
		"Join":
			pass
		"Create":
			pass
	add_child(lobby.instance())
	get_node("Hub").hide()
	
func load_game():
	add_child(game.instance())
	pass
	
func transition():
	add_child(transition.instance())
	delete_children()
	
func delete_children():
	for n in get_children():
		if (n.name != "Transition"):
			remove_child(n)
			n.queue_free()
