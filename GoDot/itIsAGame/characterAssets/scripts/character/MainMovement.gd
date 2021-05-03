extends KinematicBody

var Character_Details = load("res://characterAssets/scripts/character/CharacterDetails.gd") # Relative path
onready var charDet = Character_Details.new()

var AnimHandler = load("res://characterAssets/scripts/character/AnimationHandler.gd")
onready var animationHandler = AnimHandler.new($AnimationPlayer, charDet, $Timer)

const SPEED_WALK = 15
const SPEED_RUN = 30
const JUMP_FORCE = 60
const GRAVITY = 1.3
const SPEED_MAX_FALL = -40

var yVelo = 0
var grounded = is_on_floor()
var moveVec = Vector3()
var justJumped = false
var playerState


func _ready():
	pass

func _physics_process(_delta):
	grounded = is_on_floor()
	if grounded:
		charDet.geoState.set_currState("GROUND")
	else:
		charDet.geoState.set_currState("AIR")
	moveVec = Vector3()
	justJumped = false
	
	yVelo -= GRAVITY
	if yVelo < SPEED_MAX_FALL:
		yVelo = SPEED_MAX_FALL
		
	if charDet.actionState.get_currState() != 1: #not busy
		if charDet.actionState.get_currState() == 0: #None
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
			#Jump input
			if Input.is_action_just_pressed("jump") && grounded:
				justJumped = true
				yVelo = JUMP_FORCE
			elif grounded:
				yVelo = -0.1
			#attacks / TODO need check for item
			if Input.is_action_just_pressed("light_attack"):
				animationHandler.handle_attack_animation("light_attack")
			if Input.is_action_just_pressed("heavy_attack"):
				animationHandler.handle_attack_animation("heavy_attack")
			#TODO Block
		elif charDet.actionState.get_currState() == 2: #attacking
			if Input.is_action_just_pressed("light_attack"):
				animationHandler.handle_attack_animation("light_attack")
			if Input.is_action_just_pressed("heavy_attack"):
				animationHandler.handle_attack_animation("heavy_attack")
			#Standard Attacks End
	if charDet.actionState.get_currState() == charDet.actionState.get_states()["NONE"]:
		animationHandler.handle_aerial_movement_animation(justJumped, grounded, moveVec)
	
	move_and_slide_wrapper(moveVec)
	define_player_state()
	#print(charDet.geoState.get_currState())
	
func move_and_slide_wrapper(moveVec):
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3(0, 1, 0), rotation.y)
	moveVec *= SPEED_WALK
	
	if charDet.geoState.get_currState() == charDet.geoState.get_states()["AIR"]:
		moveVec /= 2
		
	moveVec.y = yVelo
	move_and_slide(moveVec, Vector3(0, 1, 0))

func define_player_state():
	playerState = {"T": OS.get_system_time_msecs(), "P": global_transform.origin}
	#Server.send_player_state(playerState)

func _on_AnimationPlayer_animation_finished():
	animationHandler.set_to_idle()


func _on_Timer_timeout():
	animationHandler.timer_timeout() # Replace with function body.
