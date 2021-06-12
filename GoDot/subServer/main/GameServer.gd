extends Node

func _ready():
	Gateway.connect_to_server("test1", "test1", false) # for testing
	#load_login_screen()
