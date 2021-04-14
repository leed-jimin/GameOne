extends KinematicBody

var PlayerDetails = load("res://scripts/character/PlayerDetails.gd") # Relative path
onready var playerDetails = PlayerDetails.new()

var AnimHandler = load("res://scripts/character/AnimationHandler.gd")
onready var animationHandler = AnimHandler.new($AnimationPlayer)

const MOVE_SPEED = 8
const JUMP_FORCE = 30
const GRAVITY = 1.3
const MAX_FALL_SPEED = 30

const characterState = {
	IDLE = 0,
	AIRBOURNE = 1,
	ATTACKING = 2
}

var currCharState = characterState.IDLE
var y_velo = 0

onready var characterModel = $characterModel

func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	var move_vec = Vector3()
	#Directional movement
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1
		#rotate_y(deg2rad(90))
	elif Input.is_action_pressed("ui_right"):
		move_vec.x += 1
	if Input.is_action_pressed("ui_up"):
		move_vec.z -= 1
	elif Input.is_action_pressed("ui_down"):
		move_vec.z += 1
	#Standard Attacks
	if Input.is_action_just_pressed("light_attack"):
		animationHandler.handle_attack_animation("light")
	if Input.is_action_just_pressed("heavy_attack"):
		animationHandler.handle_attack_animation("heavy")
	
	move_and_slide_wrapper(move_vec)
	
	var grounded = is_on_floor()
	var just_jumped = false
	#jump handling
	if grounded:
		if Input.is_action_just_pressed("jump"):
			just_jumped = true
			y_velo = JUMP_FORCE
	else:
		y_velo -= GRAVITY
		
	animationHandler.handle_movement_animation(self, just_jumped, grounded, move_vec, currCharState, characterState)

func move_and_slide_wrapper(move_vec):
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
