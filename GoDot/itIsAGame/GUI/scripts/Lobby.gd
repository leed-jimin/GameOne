extends Control

var lobbyId = 1
var players = {}
var maps = ["test1", "test2"]
var mode = "DM"


func _ready():
	pass

func exit_to_hub():
	queue_free()

func _on_TextureButton_pressed():
	Server.request_start_game(lobbyId)
