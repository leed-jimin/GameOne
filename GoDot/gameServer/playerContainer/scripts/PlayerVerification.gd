extends Node

onready var Player_Container = preload("res://playerContainer/scenes/PlayerContainer.tscn") # Relative path

func _ready():
	pass


func start(playerId):
	#TODO Token verification
	create_player_container(playerId)

func create_player_container(playerId):
	var newPlayerContainer = Player_Container.instance()
	newPlayerContainer.name = str(playerId)
	get_parent().add_child(newPlayerContainer, true)
	var playerContainer = get_node("../" + str(playerId))
	fill_player_container(playerContainer)
	
func fill_player_container(container):
	container.playerInventory = ServerData.testData
