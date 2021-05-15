extends Control

#UI States
onready var loginScreen = get_node("Background/Login")
onready var createAccountScreen = get_node("Background/CreateAccount")
#Login screen
onready var usernameLogin = get_node("Background/Login/UsernameEdit")
onready var passwordLogin = get_node("Background/Login/PasswordEdit")
onready var loginButton = get_node("Background/Login/LoginButton")
onready var createAccountButton = get_node("Background/Login/CreateAccount")
#Create Account
onready var usernameCreate= get_node("Background/CreateAccount/UsernameEdit")
onready var passwordCreate = get_node("Background/CreateAccount/PasswordEdit")
onready var confirmPasswordCreate = get_node("Background/CreateAccount/ConfirmPasswordEdit")
onready var signUpButton = get_node("Background/CreateAccount/SignUp")
onready var cancelButton = get_node("Background/CreateAccount/Cancel")

func _ready():
	pass

func _on_LoginButton_pressed():
	if usernameLogin.text == "" or passwordLogin.text == "":
		#stop with popup
		print("invalid username or pw")
	else:
		loginButton.disabled = true
		createAccountButton.disabled = true
		var username = usernameLogin.get_text()
		var password = passwordLogin.get_text()
		print("trying to login")
		Gateway.connect_to_server(username, password, false)

func _on_Sign_Up_pressed():
	var valid = true
	if usernameCreate.get_text() == null:
		print("Please provide a valid username.")
		valid = false
	if passwordCreate.get_text() == null:
		print("Please provide a valid password.")
		valid = false
	if confirmPasswordCreate.get_text() == null:
		print("Passwords don't match.")
		valid = false
	#need extra handling
	if valid:
		signUpButton.disabled = true
		cancelButton.disabled = true
		Gateway.connect_to_server(usernameCreate.get_text(), passwordCreate.get_text(), true)
	
func _on_CreateAccount_pressed():
	loginScreen.hide()
	createAccountScreen.show()


func _on_Cancel_pressed():
	createAccountScreen.hide()
	loginScreen.show()
