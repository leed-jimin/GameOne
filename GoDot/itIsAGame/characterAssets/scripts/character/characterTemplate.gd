extends KinematicBody

var attackDict = {}
var state = "Idle"

onready var anim = get_node("AnimationPlayer")
#TODO
func move_player(newPosition, rotationVector):
	if not state == "Attack":
		if transform.origin == newPosition:
			state = "Idle"
			anim.play("Idle")
		else:
			state = "Idle"
			anim.play("Walking")
			transform.origin = newPosition
			rotation_degrees = rotationVector
	
func _physics_process(delta):
	if not attackDict == {}:
		attack()
	
func attack():
	for attack in attackDict.keys():
		if attack <= Server.clientClock:
			state = "Attack"
			anim.play(attackDict[attack])
			
			yield(get_tree().create_timer(0.5), "timeout")
			
			state = "Idle"
