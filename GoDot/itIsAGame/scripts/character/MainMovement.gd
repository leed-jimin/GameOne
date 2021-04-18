extends KinematicBody

var PlayerDetails = load("res://scripts/character/PlayerDetails.gd") # Relative path
onready var playerDetails = PlayerDetails.new()

var AnimHandler = load("res://scripts/character/AnimationHandler.gd")
onready var animationHandler = AnimHandler.new($AnimationPlayer)

const MOVE_SPEED = 8
const JUMP_FORCE = 50
const GRAVITY = 1.3
const MAX_FALL_SPEED = 40

const characterState = {
	"IDLE": 0,
	"AIRBOURNE": 1,
	"ATTACKING": 2
}

var currCharState = characterState["IDLE"]
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
		animationHandler.handle_attack_animation("light_attack")
	if Input.is_action_just_pressed("heavy_attack"):
		animationHandler.handle_attack_animation("heavy_attack")
	
	move_and_slide_wrapper(move_vec)
	
	#jumping logic
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_just_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
 
	if just_jumped:
		animationHandler.play_anim("JumpUp", false)
		currCharState = characterState["AIRBOURNE"];
	elif grounded and int(currCharState) == characterState["AIRBOURNE"]:
		currCharState = characterState["IDLE"];
		animationHandler.play_anim("FallDown", true)
	elif grounded:
		currCharState = characterState["IDLE"];
		if move_vec.x == 0 and move_vec.z == 0:
			animationHandler.play_anim("Idle", false)
		else:
			animationHandler.play_anim("Walking", false)
		
	#currCharState = animationHandler.handle_aerial_movement_animation(just_jumped, grounded, move_vec, currCharState, characterState)
	#end jumping logic
	
func handle_aerial_movement():
	pass
	
func move_and_slide_wrapper(move_vec):
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
