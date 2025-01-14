extends Node

class_name AnimationHandler

@onready var animationPlayer = get_node("../CharacterModel/AnimationPlayer")
@onready var timer = get_node("../Timer")
@onready var animationTree = get_node("../CharacterModel/AnimationTree")
@onready var inputBuffer = get_node("../InputBuffer")

var atkPoints = 0
var lightWaitTime = .7
var heavyWaitTime = 1
var YN = Globals.YN

func _ready():
	animationPlayer.get_animation("walk").set_loop(true)
	animationPlayer.get_animation("idle").set_loop(true)
	animationPlayer.get_animation("run").set_loop(true)
	animationPlayer.get_animation("falling").set_loop(true)
	animationTree.active = true

func handle_aerial_movement_animation(grounded, moveVec, justJumped):
	if justJumped:
		animationTree.set("parameters/jump-fall/current", 0)
		animationTree.set("parameters/onGround/current", YN.NO)
	elif false: #landing anim #TODO Fix later not urgent
		animationTree.set("parameters/actionType/current", 2)
		animationTree.set("parameters/isAction/current", YN.YES)
	elif grounded:
		animationTree.set("parameters/onGround/current", YN.YES)
		animationTree.set("parameters/isAirAction/current", YN.NO)
		if moveVec.x == 0 and moveVec.z == 0: #Idle
			animationTree.set_idle()
		elif inputBuffer.is_run_input() or animationTree.get("parameters/movement/blend_amount") == 1: #run
			timer.start()
			animationTree.set_run()
		else:
			timer.start()
			animationTree.set_walk()
	else: #falling
		animationTree.set("parameters/jump-fall/current", 1)
		animationTree.set("parameters/isAction/current", YN.NO)
		animationTree.set("parameters/onGround/current", YN.NO)
	
func handle_attack_animation(type):
	if type == "light_attack":
		if animationTree.get("parameters/onGround/current") == YN.NO:
			animationTree.set_attack(Globals.AttackTypes.LIGHT, Globals.AIR)
		else:
			timer.wait_time = lightWaitTime
			animationTree.set_attack(Globals.AttackTypes.LIGHT, Globals.GROUND)
	elif type == "heavy_attack":
		if animationTree.get("parameters/onGround/current") == YN.NO:
			animationTree.set_attack(Globals.AttackTypes.HEAVY, Globals.AIR)
		else:
			timer.wait_time = heavyWaitTime
			animationTree.set_attack(Globals.AttackTypes.HEAVY, Globals.GROUND)
		
func handle_block_animation():
	pass
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	pass

func timer_timeout():
#	set_to_idle()
	atkPoints = 0
	inputBuffer.purge()
	timer.stop()


func on_hit(damage):
	animationPlayer.play("lightDamage")

func _on_headHB_body_entered(body):
	pass # Replace with function body.

func _on_torsoHB_body_entered(body):
	pass # Replace with function body.

func _on_lHandHB_body_entered(body):
	if animationTree.is_attacking():
		if body.is_in_group("OtherPlayers") or body.is_in_group("Enemies"):
			print("hit")
			#Server.send_character_hit(body.name, get_node("../rig/Skeleton/leftHandBone").global_transform.origin, body.transform.origin)

func _on_rHandHB_body_entered(body):
	if animationTree.is_attacking():
		if body.is_in_group("OtherPlayers") or body.is_in_group("Enemies"):
			#Server.send_character_hit(get_parent().transform.origin, get_node("../rig/Skeleton/rightHandBone").global_transform.origin, body.transform.origin)
			pass
