extends KinematicBody

var Player_Details = load("res://scripts/character/PlayerDetails.gd") # Relative path
onready var playerDetails = Player_Details.new()

var AnimHandler = load("res://scripts/character/AnimationHandler.gd")
onready var animationHandler = AnimHandler.new($AnimationPlayer, $AnimationTree, playerDetails, $Timer)

const SPEED_WALK = 15
const SPEED_RUN = 30
const JUMP_FORCE = 60
const GRAVITY = 1.3
#const SPEED_MAX_FALL = 40

var yVelo = 0
var airbourne = false
var charStates

onready var characterModel = $characterModel

func _ready():
	charStates = playerDetails.get_characterStates()
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	var moveVec = Vector3()
	#Directional movement
	if Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_up"):
			rotation_degrees = Vector3(0, -135, 0)
		elif Input.is_action_pressed("ui_down"):
			rotation_degrees = Vector3(0, -45, 0)
		else:
			rotation_degrees = Vector3(0, -90, 0)
		moveVec.z += 1
	elif Input.is_action_pressed("ui_right"):
		if Input.is_action_pressed("ui_up"):
			rotation_degrees = Vector3(0, 135, 0)
		elif Input.is_action_pressed("ui_down"):
			rotation_degrees = Vector3(0, 45, 0)
		else:
			rotation_degrees = Vector3(0, 90, 0)
		moveVec.z += 1
	elif Input.is_action_pressed("ui_up"):
		rotation_degrees = Vector3(0, 180, 0)
		moveVec.z += 1
	elif Input.is_action_pressed("ui_down"):
		rotation_degrees = Vector3(0, 0, 0)
		moveVec.z += 1
	#Directional movement End
	
	#Jumping logic
	var grounded = is_on_floor()
	var just_jumped = false
	
	if grounded:
		if Input.is_action_just_pressed("jump"):
			just_jumped = true
			yVelo = JUMP_FORCE
	else:
		playerDetails.set_currCharState(charStates["AIRBOURNE"])
		yVelo -= GRAVITY
		
	#print(playerDetails.get_currCharState())
	if playerDetails.get_currCharState() != charStates["ACTION"]:
		move_and_slide_wrapper(moveVec)
		animationHandler.handle_aerial_movement_animation(just_jumped, grounded, moveVec)
	#Jumping logic End
	
	#Standard Attacks
	if Input.is_action_just_pressed("light_attack"):
		animationHandler.handle_attack_animation("light_attack")
	if Input.is_action_just_pressed("heavy_attack"):
		animationHandler.handle_attack_animation("heavy_attack")
	#Standard Attacks End
	
func move_and_slide_wrapper(moveVec):
	var currSpeed = SPEED_WALK
	if playerDetails.get_currCharState() == charStates["AIRBOURNE"]:
		currSpeed = SPEED_WALK / 2
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3(0, 1, 0), rotation.y)
	moveVec *= currSpeed
	moveVec.y = yVelo
	move_and_slide(moveVec, Vector3(0, 1, 0))


func _on_AnimationPlayer_animation_finished(anim_name):
	animationHandler.set_to_idle()


func _on_Timer_timeout():
	animationHandler.timer_timeout() # Replace with function body.
