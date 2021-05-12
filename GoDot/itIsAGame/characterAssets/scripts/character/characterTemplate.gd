extends KinematicBody

var States = load("res://characterAssets/scripts/character/States.gd") # Relative path

var attackDict = {}

const actionStates = {
	"NONE": 0,
	"BUSY": 1,
}

var actionState

onready var anim = get_node("AnimationPlayer")

func _ready():
	actionState = States.new(actionStates, "NONE")

func move_player(newPosition, rotationVector):
	if not actionState.get_currState() == 1:
		if transform.origin.is_equal_approx(newPosition):
			anim.play("Idle")
		else:
			anim.play("Walking")
			transform.origin = newPosition
			rotation_degrees = rotationVector
	
func _physics_process(delta):
	if attackDict.size() > 0:
		attack()
	
func attack():
	for time in attackDict.keys():
		if time <= Server.clientClock:
			actionState.set_currState("BUSY")
			anim.play(attackDict[time]["Attack"])
			attackDict.erase(time)
			yield(get_tree().create_timer(0.5), "timeout")
			
			actionState.set_currState("NONE")

func on_hit(damage):
	actionState.set_currState("BUSY")
	anim.play("lightDamage")
	yield(get_tree().create_timer(0.5), "timeout")
	actionState.set_currState("NONE")
	print("taking hit")
