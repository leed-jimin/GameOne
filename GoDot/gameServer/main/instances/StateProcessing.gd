extends Node

var worldState

func _physics_process(delta):
	
	var server = get_node("/root/Server")
	if not server.playerStateCollection.empty():
		worldState = server.playerStateCollection.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
		worldState["Enem"] = server.get_node("GameLogic").enemyList
		#verification
		#Anti-cheat
		#cuts
		#physics check
		#anything else
		server.send_world_state(worldState)
