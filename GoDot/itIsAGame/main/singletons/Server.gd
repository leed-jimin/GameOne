extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909
var token

var Player_Stats = preload("res://main/userDetails/PlayerStats.tscn")

func _ready():
	pass
	#connect_to_server()
	
func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")

func _on_connection_succeeded():
	print("connection success")
	fetch_player_inventory()
	
func _on_connection_failed():
	print("connection fail")

remote func fetch_token():
	rpc_id(1, "return_token", token)

remote func return_token_verification_results(result):
	print("received token results")
	if result == true:
		get_node("/root/SceneHandler/MainScreen").queue_free()
		get_node("/root/SceneHandler").player_verified()
		print("successful token verification")
	else:
		print("login failed; try again")
		get_node("MainScreen/NinePatchRect/VBoxContainer/LoginButton").disabled = false

func send_player_state(playerState):
	rpc_unreliable_id(1, "receive_player_state", playerState)

remote func receive_world_state(worldState):
	get_node("/root/SceneHandler").update_world_state(worldState)

remote func spawn_new_player(playerId, spawnPosition):
	get_node("/root/SceneHandler").spawn_new_player(playerId, spawnPosition)
	
remote func despawn_player(playerId):
	get_node("/root/SceneHandler").despawn_player(playerId)

#server calls for player info
func fetch_player_inventory():
	rpc_id(1, "fetch_player_inventory")
	
remote func return_player_inventory(inventory):
	#TODO I'm not sure where yet
	if not inventory == null:
		var newPlayerStats = Player_Stats.instance()
		get_parent().add_child(newPlayerStats, true)
		print(inventory)
	#get_node("/root/SceneHandler/characterModel")
