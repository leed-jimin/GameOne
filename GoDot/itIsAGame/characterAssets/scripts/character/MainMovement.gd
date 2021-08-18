extends KinematicBody

onready var charDet = get_node("CharacterDetails")

const SPEED_WALK = 15
const SPEED_RUN = 30
const JUMP_FORCE = 60
const GRAVITY = 1.3
const SPEED_MAX_FALL = -40

var left
var right
var up
var down

var yVelo = 0
var grounded = is_on_floor()
var moveVec = Vector3()
var justJumped = false
var playerState

var currentHp = 100

#TODO use the position of bone to detect collision on server side
func _ready():
	pass

func _physics_process(_delta):
	justJumped = false
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	grounded = is_on_floor()
	
	if grounded:
		charDet.geoState.set_currState("GROUND")
	else:
		charDet.geoState.set_currState("AIR")
		yVelo -= GRAVITY
		
	moveVec = Vector3()
	
	if yVelo < SPEED_MAX_FALL:
		yVelo = SPEED_MAX_FALL
		
	if charDet.actionState.get_currState() != 1: #not busy
		if charDet.actionState.get_currState() == 0: #None
			#Directional movement
			moveVec.x = int(right) - int(left)
			moveVec.z = int(down) - int(up)
			handle_rotation()
			#Jump input
			if Input.is_action_just_pressed("jump") && grounded:
				justJumped = true
				yVelo = JUMP_FORCE
			elif grounded:
				yVelo = -0.1
			#Block input
			if Input.is_action_just_pressed("light_attack") and Input.is_action_just_pressed("heavy_attack"):
				get_node("AnimationHandler").handle_block_animation()
			#attacks / TODO need check for item
			elif Input.is_action_just_pressed("light_attack"):
				get_node("AnimationHandler").handle_attack_animation("light_attack")
			elif Input.is_action_just_pressed("heavy_attack"):
				get_node("AnimationHandler").handle_attack_animation("heavy_attack")

		elif charDet.actionState.get_currState() == 2: #attacking
			if Input.is_action_just_pressed("light_attack"):
				get_node("AnimationHandler").handle_attack_animation("light_attack")
			if Input.is_action_just_pressed("heavy_attack"):
				get_node("AnimationHandler").handle_attack_animation("heavy_attack")
			#Standard Attacks End
	if charDet.actionState.get_currState() == charDet.actionState.get_states()["NONE"]:
		get_node("AnimationHandler").handle_aerial_movement_animation(grounded, moveVec, justJumped, yVelo)
	
	move_and_slide_wrapper(moveVec)
	#define_player_state()

func handle_rotation():
	if left:
		if up:
			rotate_model(Vector3(0, -135, 0))
		elif down:
			rotate_model(Vector3(0, -45, 0))
		else:
			rotate_model(Vector3(0, -90, 0))
	elif right:
		if up:
			rotate_model(Vector3(0, 135, 0))
		elif down:
			rotate_model(Vector3(0, 45, 0))
		else:
			rotate_model(Vector3(0, 90, 0))
	elif up:
		rotate_model(Vector3(0, 180, 0))
	elif down:
		rotate_model(Vector3(0, 0, 0))

func rotate_model(rotationVector):
	get_node("rig").rotation_degrees = rotationVector
	get_node("CollisionShape").rotation_degrees = rotationVector

func move_and_slide_wrapper(moveVec):
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3(0, 1, 0), rotation.y)
	moveVec *= SPEED_WALK
	
	if charDet.geoState.get_currState() == charDet.geoState.get_states()["AIR"]:
		moveVec /= 1.5
		
	moveVec.y = yVelo
	move_and_slide(moveVec, Vector3(0, 1, 0))

func define_player_state():
	playerState = {"T": OS.get_system_time_msecs(), "P": transform.origin, "R": rotation_degrees}
	Server.send_player_state(playerState)

func _on_AnimationPlayer_animation_finished(animationName):
	get_node("AnimationHandler").set_to_idle()

func _on_Timer_timeout():
	get_node("AnimationHandler").timer_timeout() # Replace with function body.
