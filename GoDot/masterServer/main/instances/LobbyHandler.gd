extends Node

var lobbyDict = {}
var lobbyCount = 0; # this will have to change so that gameId can be the same
onready var MasterServer = get_node("/root/MasterServer")
const LobbyState = {
	OPEN = "Open",
	FULL = "Full",
	INGAME = "In Game",
	ENDING = "Ending",
}

func _ready():
	pass

func update_lobbies():
	#update based on timer or request
	pass

func create_lobby(playerId):
	lobbyCount += 1
	lobbyDict[lobbyCount] = {"max": 8, "state": LobbyState.OPEN, "players": [playerId]}
	print(lobbyDict)
	MasterServer.lobby_created(lobbyCount)

func join_lobby(lobbyId, playerId):
	if lobbyDict[lobbyId]["Players"].length() < lobbyDict[lobbyId]["Max"]:
		lobbyDict[lobbyId]["Players"].add(playerId)
		MasterServer.joined_lobby(true)
	else:
		MasterServer.joined_lobby(false)

func leave_lobby(lobbyId, playerId):
	if lobbyDict[lobbyId]["Players"].has(playerId):
		lobbyDict[lobbyId]["Players"].erase(playerId)
		MasterServer.lobby_left()
	if lobbyDict[lobbyId]["Players"].length() <= 0:
		close_lobby(lobbyId)
		
func close_lobby(lobbyId):
	lobbyDict.erase(lobbyId)
	update_lobbies()
	
func start_game(lobbyId):
	#getter for ip and port
	for playerId in lobbyDict[lobbyId]["players"]:
		MasterServer.game_starting(playerId, "127.0.0.1", 1908)
