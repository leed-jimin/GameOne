extends CharacterBody3D

@onready var characterDetails = $CharacterDetails
@onready var inputBuffer = $InputBuffer
@onready var timer = $Timer
@onready var animationHandler = $AnimationHandler
@onready var animationTree = $CharacterModel/AnimationTree
@onready var characterModel = $CharacterModel

const SPEED_WALK = 8
const SPEED_RUN = SPEED_WALK * 3
const JUMP_FORCE = 30
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

var rootMotion = Transform3D()
var airDrift = Vector3()
var yVelo = 0
var grounded
var moveVec
var justJumped = false
var playerState

var currentHp = 100

func _ready():
	moveVec = Vector3()
	characterDetails.get_attack_patterns()
	#set_physics_process(false)

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
		move_and_slide_wrapper()
		store_movement_input()

	elif animationTree.is_attacking(): #attacking
		if Input.is_action_just_pressed("light_attack"):
			inputBuffer.insert(InputType.LIGHT)
			animationHandler.handle_attack_animation("light_attack")
		if Input.is_action_just_pressed("heavy_attack"):
			inputBuffer.insert(InputType.HEAVY)
			animationHandler.handle_attack_animation("heavy_attack")
		
		root_motion_move_and_slide(delta)
		#Standard Attacks End

	animationHandler.handle_aerial_movement_animation(grounded, moveVec, justJumped)
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
	characterModel.rotation_degrees = rotationVector
	
func move_and_slide_wrapper():
	moveVec = moveVec.normalized()
	moveVec = moveVec.rotated(Vector3.UP, rotation.y)
	
	if not grounded:
		airDrift.x = max(min(airDrift.x + moveVec.x * .3, SPEED_RUN), -SPEED_RUN)
		airDrift.z = max(min(airDrift.z + moveVec.z * .3, SPEED_RUN), -SPEED_RUN)
		airDrift.y = yVelo
		set_velocity(airDrift)
		set_up_direction(Vector3.UP)
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		return
		
	if animationTree.get("parameters/movement/blend_amount") == 1:
		moveVec *= SPEED_RUN
	elif animationTree.get("parameters/movement/blend_amount") == 0:
		moveVec *= SPEED_WALK

	moveVec.y = yVelo

	set_velocity(moveVec)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	airDrift = velocity

func root_motion_move_and_slide(delta):
	rootMotion = animationTree.get_root_motion_transform()

	var h_velocity = rootMotion.origin / delta
	moveVec.x = h_velocity.x
	moveVec.z = h_velocity.z
	moveVec.y = yVelo

	set_velocity(characterModel.global_transform.basis * (moveVec))
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()

	rootMotion = rootMotion.orthonormalized() # Orthonormalize orientation.
	moveVec = Vector3()

func define_player_state():
	playerState = {"T": Time.get_ticks_msec(), "P": transform.origin, "R": characterModel.rotation_degrees} #could be global transform
	if grounded:
		playerState["M"] = animationTree.get("parameters/movement/blend_amount") # add jump or nah
	else:
		playerState["M"] = 2
		
	GameServer.send_player_state(playerState)

func store_movement_input():
	if Input.is_action_just_pressed("ui_left"):
		inputBuffer.insert(InputType.LEFT)
	elif Input.is_action_just_pressed("ui_up"):
		inputBuffer.insert(InputType.UP)
	if Input.is_action_just_pressed("ui_right"):
		inputBuffer.insert(InputType.RIGHT)
	elif Input.is_action_just_pressed("ui_down"):
		inputBuffer.insert(InputType.DOWN)
