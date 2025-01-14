extends Node

var PlayerIDs
var ServerIDs

func _ready():
	var playerID_file = FileAccess.open("res://data/player_id_test.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(playerID_file.get_as_text())
	var json = test_json_conv.get_data()
	playerID_file.close()
	PlayerIDs = json
	
	var serverID_file = FileAccess.open("res://data/game_server_id.json", FileAccess.READ)
	test_json_conv = JSON.new()
	test_json_conv.parse(serverID_file.get_as_text())
	json = test_json_conv.get_data()
	serverID_file.close()
	ServerIDs = json

func SavePlayerIDs():
	var saveFile = FileAccess.open("res://data/player_id_test.json", FileAccess.WRITE)
	saveFile.store_line(JSON.stringify(PlayerIDs))
	saveFile.close()
