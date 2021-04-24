extends KinematicBody

var Character_Details = load("res://characterAssets/scripts/character/CharacterDetails.gd") # Relative path
onready var characterDetails = Character_Details.new()

var AnimHandler = load("res://characterAssets/scripts/character/AnimationHandler.gd")
onready var animationHandler = AnimHandler.new($AnimationPlayer, $AnimationTree, characterDetails, $Timer)

const SPEED_WALK = 15
const SPEED_RUN = 30
const JUMP_FORCE = 60
const GRAVITY = 1.3
#const SPEED_MAX_FALL = 40

var yVelo = 0
var airbourne = false

#onready var characterModel = $characterModel

func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	var moveVec = Vector3()
	#Directional movement
	if characterDetails.actionState.get_currState() == 0:
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
		if Input.is_action_just_pressed("jump") && characterDetails.actionState.get_currState() == 0:
			just_jumped = true
			yVelo = JUMP_FORCE
	else:
		characterDetails.geoState.set_currState("AIR")
		yVelo -= GRAVITY
		
	#print(playerDetails.get_currCharState())
	if characterDetails.actionState.get_currState() == characterDetails.actionState.get_states()["NONE"] || characterDetails.geoState.get_currState() == characterDetails.geoState.get_states()["AIR"]:
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
	if characterDetails.geoState.get_currState() == characterDetails.geoState.get_states()["AIR"]:
		currSpeed = SPEED_WALK / 2
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3(0, 1, 0), rotation.y)
	moveVec *= currSpeed
	moveVec.y = yVelo
	move_and_slide(moveVec, Vector3(0, 1, 0))


func _on_AnimationPlayer_animation_finished():
	animationHandler.set_to_idle()


func _on_Timer_timeout():
	animationHandler.timer_timeout() # Replace with function body.
