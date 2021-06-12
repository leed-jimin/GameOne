extends Node

var lobbyDict = {}
var lobbyCount = 0; # this will have to change so that gameId can be the same
onready var server = get_node("/root/Server")
#onready var stateProcessing = load("res://main/scenes/StateProcessing.tscn")

func _ready():
	pass

func update_lobbies():
	#update based on timer or request
	pass

func create_lobby(playerId):
	lobbyCount += 1
	lobbyDict[lobbyCount] = {"MaxPlayers": 8, "State": "Open", "Members": [playerId]}
	print(lobbyDict)
	server.lobby_created(lobbyCount)

func join_lobby(lobbyId, playerId):
	if lobbyDict[lobbyId]["Members"].length() < lobbyDict[lobbyId]["MaxPlayers"]:
		lobbyDict[lobbyId]["Members"].add(playerId)
		server.joined_lobby(true)
	else:
		server.joined_lobby(false)

func leave_lobby(lobbyId, playerId):
	if lobbyDict[lobbyId]["Members"].has(playerId):
		lobbyDict[lobbyId]["Members"].erase(playerId)
		server.lobby_left()
	if lobbyDict[lobbyId]["Members"].length() <= 0:
		close_lobby(lobbyId)
		
func close_lobby(lobbyId):
	lobbyDict.erase(lobbyId)
	update_lobbies()
	
func start_game(lobbyId):
	pass
