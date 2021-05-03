extends Node

var worldState

func _physics_process(delta):
	if not get_parent().playerStateCollection.empty():
		worldState = get_parent().playerStateCollection.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
		#verification
		#Anti-cheat
		#cuts
		#physics check
		#anything else
		get_parent().send_world_state(worldState)
