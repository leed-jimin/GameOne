extends Node

var PlayerIDs
var ServerIDs

func _ready():
	var playerID_file = File.new()
	playerID_file.open("res://data/player_id_test.json", File.READ)
	var json = JSON.parse(playerID_file.get_as_text())
	playerID_file.close()
	PlayerIDs = json.result
	
	var serverID_file = File.new()
	serverID_file.open("res://data/game_server_id.json", File.READ)
	json = JSON.parse(serverID_file.get_as_text())
	serverID_file.close()
	ServerIDs = json.result

func SavePlayerIDs():
	var saveFile = File.new()
	saveFile.open("res://data/player_id_test.json", File.WRITE)
	saveFile.store_line(to_json(PlayerIDs))
	saveFile.close()
