extends Control

onready var usernameInput = get_node("NinePatchRect/VBoxContainer/UsernameEdit")
onready var passwordInput = get_node("NinePatchRect/VBoxContainer/PasswordEdit")
onready var loginButton = get_node("NinePatchRect/VBoxContainer/LoginButton")

func _ready():
	pass

func _on_LoginButton_pressed():
	if usernameInput.text == "" or passwordInput.text == "":
		#stop with popup
		print("invalid username or pw")
	else:
		get_node("NinePatchRect/VBoxContainer/LoginButton").disabled = true
		var username = usernameInput.get_text()
		var password = passwordInput.get_text()
		print("trying to login")
		Gateway.connect_to_server(username, password)
