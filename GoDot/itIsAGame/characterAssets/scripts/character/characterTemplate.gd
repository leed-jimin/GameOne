extends KinematicBody

onready var characterModel = $CharacterModel
onready var animationPlayer = characterModel.get_node("AnimationPlayer")

var attackDict = {}


func move_player(newPosition, rotationVector):
	rotate_model(rotationVector)
	if transform.origin.is_equal_approx(newPosition):
		animationPlayer.play("Idle")
	else:
		animationPlayer.play("walk")
		transform.origin = newPosition

func _physics_process(delta):
	if attackDict.size() > 0:
		attack()
		
func rotate_model(rotationVector):
	characterModel.rotation_degrees = rotationVector
	
func attack():
	for time in attackDict.keys():
		if time <= GameServer.clientClock:
			animationPlayer.play(attackDict[time])
			attackDict.erase(time)

func on_hit(damage):
	animationPlayer.play("lightDamage")
	yield(get_tree().create_timer(0.5), "timeout")
	print("taking hit")
