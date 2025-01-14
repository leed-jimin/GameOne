extends CharacterBody3D

@onready var characterModel = $CharacterModel
@onready var animationTree = $CharacterModel/AnimationTree
@onready var animationPlayer = $CharacterModel/AnimationPlayer

const YN = Globals.YN

var groundActionNode
var airActionNode
var grounded
var actionDict = {}

func _ready():
	animationPlayer.get_animation("idle").loop = true
	animationPlayer.get_animation("run").loop = true
	animationPlayer.get_animation("walk").loop = true
	animationTree.active = true
	groundActionNode = animationTree.tree_root.get_node("actionGround")
	airActionNode = animationTree.tree_root.get_node("actionAir")

func move_player(newPosition, rotationVector, movement):
	rotate_model(rotationVector)
	if movement == 2:
		grounded = false
		animationTree.set("parameters/onGround/current", YN.NO)
	else:
		grounded = true
		animationTree.set("parameters/onGround/current", YN.YES)
		if movement == 0:
			animationTree.set_walk()
		elif movement == 1:
			animationTree.set_run()
		else:
			animationTree.set_idle()
		
	transform.origin = newPosition
	set_velocity(Vector3(0, 0, 0))
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()

func _physics_process(_delta):
	if actionDict.size() > 0:
		action()
		
func rotate_model(rotationVector):
	characterModel.rotation_degrees = rotationVector
	
func action():
	for time in actionDict.keys():
		if time <= GameServer.clientClock:
			if grounded:
				groundActionNode.set_animation(actionDict[time])
				animationTree.set_action_ground()
			else:
				airActionNode.set_animation(actionDict[time])
				animationTree.set_action_air()
				
		actionDict.erase(time)

func on_hit(damage):
#	animationPlayer.play("lightDamage")
	print("taking hit")
