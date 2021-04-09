extends KinematicBody

const PlayerDetails = preload("playerDetails.gd") # Relative path
onready var playerDetails = PlayerDetails.new()

const MOVE_SPEED = 8
const JUMP_FORCE = 30
const GRAVITY = 1.3
const MAX_FALL_SPEED = 30
var airbourne = false;
var y_velo = 0

onready var characterModel = $characterModel
onready var anim = $animations

func _ready():
	anim.get_animation("Walking").set_loop(true)
	anim.get_animation("Idle").set_loop(true)
	anim.get_animation("Running").set_loop(true)
	anim.play("Idle")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	var move_vec = Vector3()
	
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1
		rotate_y(deg2rad(90))
	elif Input.is_action_pressed("ui_right"):
		move_vec.x += 1
	if Input.is_action_pressed("ui_up"):
		move_vec.z -= 1
	elif Input.is_action_pressed("ui_down"):
		move_vec.z += 1
	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
	
	var grounded = is_on_floor()
	var just_jumped = false
	
	if grounded:
		if Input.is_action_just_pressed("jump"):
			just_jumped = true
			y_velo = JUMP_FORCE
	else:
		y_velo -= GRAVITY
		
	handle_anim(just_jumped, grounded, move_vec)
	

func handle_anim(just_jumped, grounded, move_vec):
	if just_jumped:
		play_anim("JumpUp")
		airbourne = true
	elif airbourne and is_on_floor():
		play_anim("FallDown")
		yield(anim, "animation_finished")
		airbourne = false
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			play_anim("Idle")
		else:
			play_anim("Walking")

func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)
