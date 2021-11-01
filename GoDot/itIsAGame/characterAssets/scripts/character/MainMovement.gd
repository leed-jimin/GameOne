extends KinematicBody

onready var characterDetails = $CharacterDetails
onready var inputBuffer = $InputBuffer
onready var timer = $Timer
onready var animationHandler = $CharacterModel/AnimationHandler
onready var animationTree = $CharacterModel/AnimationTree
onready var CharacterModel = $CharacterModel

const SPEED_WALK = 4
const SPEED_RUN = 14
const JUMP_FORCE = 40
const GRAVITY = 1.4
const SPEED_MAX_FALL = -50
enum InputType {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	JUMP,
	LIGHT,
	HEAVY,
	TARGET,
}

var left
var right
var up
var down

var orientation = Transform()
var root_motion = Transform()
var yVelo = 0
var grounded
var moveVec
var justJumped = false
var playerState

var currentHp = 100

func _ready():
	orientation = global_transform
	orientation.origin = Vector3()

func _physics_process(delta):
	justJumped = false
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	grounded = is_on_floor()

	if not grounded:
		yVelo -= GRAVITY
		
		if yVelo < SPEED_MAX_FALL:
			yVelo = SPEED_MAX_FALL
	else: 
		yVelo = -GRAVITY
		
	moveVec = Vector3()

	if animationTree.is_idle(): #None
		#Directional movement
		moveVec.x = int(right) - int(left)
		moveVec.z = int(down) - int(up)
		handle_rotation()
		#Jump input
		if Input.is_action_just_pressed("jump") && grounded:
			inputBuffer.insert(InputType.JUMP)
			justJumped = true
			yVelo = JUMP_FORCE
		#Block input
		if Input.is_action_just_pressed("light_attack") and Input.is_action_just_pressed("heavy_attack"):
			animationHandler.handle_block_animation()
		#attacks / TODO need check for item
		elif Input.is_action_just_pressed("light_attack"):
			inputBuffer.insert(InputType.LIGHT)
			animationHandler.handle_attack_animation("light_attack")
		elif Input.is_action_just_pressed("heavy_attack"):
			inputBuffer.insert(InputType.HEAVY)
			animationHandler.handle_attack_animation("heavy_attack")

	elif animationTree.is_attacking(): #attacking
		if Input.is_action_just_pressed("light_attack"):
			inputBuffer.insert(InputType.LIGHT)
			animationHandler.handle_attack_animation("light_attack")
		if Input.is_action_just_pressed("heavy_attack"):
			inputBuffer.insert(InputType.HEAVY)
			animationHandler.handle_attack_animation("heavy_attack")
		#Standard Attacks End
	#THIS BLOCK NEEDS TO BE FIXED
#	root_motion = animationTree.get_root_motion_transform()
#	print(root_motion)
#	orientation *= root_motion
#	var h_velocity = orientation.origin / delta
#	moveVec.x = h_velocity.x
#	moveVec.z = h_velocity.z
#	moveVec += GRAVITY * delta

#	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
#	orientation = orientation.orthonormalized() # Orthonormalize orientation.

#	player_model.global_transform.basis = orientation.basis
# THIS BLOCK ABOVE NEEDS TO BE FIXED
	store_movement_input()
	animationHandler.handle_aerial_movement_animation(grounded, moveVec, justJumped)
	move_and_slide_wrapper(moveVec)
#	define_player_state()

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
	CharacterModel.rotation_degrees = rotationVector

func move_and_slide_wrapper(moveVec):
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3.UP, rotation.y)
	moveVec *= SPEED_WALK
	
	if animationTree.is_idle_air():
		moveVec /= 1.5
	elif animationTree.get("parameters/movement/blend_amount") == 1:
		moveVec *= 2.5
	
	moveVec.y = yVelo
	move_and_slide(moveVec, Vector3.UP, true)

func define_player_state():
	playerState = {"T": OS.get_system_time_msecs(), "P": transform.origin, "R": rotation_degrees}
	Server.send_player_state(playerState)

func store_movement_input():
	if Input.is_action_just_pressed("ui_left"):
		inputBuffer.insert(InputType.LEFT)
	elif Input.is_action_just_pressed("ui_up"):
		inputBuffer.insert(InputType.UP)
	if Input.is_action_just_pressed("ui_right"):
		inputBuffer.insert(InputType.RIGHT)
	elif Input.is_action_just_pressed("ui_down"):
		inputBuffer.insert(InputType.DOWN)
