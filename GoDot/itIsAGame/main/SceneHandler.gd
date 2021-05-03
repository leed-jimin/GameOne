extends Node

var playerStats = preload("res://main/userDetails/PlayerStats.tscn")
var characterTemplate = preload("res://characterAssets/scenes/characterTemplate.tscn")
var characterModel = preload("res://characterAssets/scenes/characterModel.tscn")
var lastWorldState = 0

func _ready():
	pass
	
func player_verified():
	var model = characterModel.instance()
	add_child(model)
	
	
#other player logic	
func spawn_new_player(playerId, spawnPosition):
	if get_tree().get_network_unique_id() == playerId:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node(str(playerId)): 
			var newPlayer = characterTemplate.instance()
			newPlayer.global_transform.origin = spawnPosition # might not work
			newPlayer.name = str(playerId)
			get_node("YSort/OtherPlayers").add_child(newPlayer)
		
func despawn_player(playerId):
	get_node(str(playerId)).queue_free()

func update_world_state(worldState):
	#Buffer
	#Interpolation
	#Extrapolation
	#rubber banding
	if worldState["T"] < lastWorldState:
		lastWorldState = worldState["T"]
		worldState.erase("T")
		worldState.erase(get_tree().get_network_unique_id())
		for player in worldState.keys():
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				get_node("YSort/OtherPlayers/" + str(player)).move_player(worldState[player]["P"])
			else:
				print("spawning player")
				spawn_new_player(player, worldState[player]["P"])
