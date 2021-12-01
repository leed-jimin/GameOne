extends Node

class_name AnimationHandler

onready var animationPlayer = get_node("../CharacterModel/AnimationPlayer")
onready var timer = get_node("../Timer")
onready var characterDetails = get_node("../CharacterDetails")
onready var animationTree = get_node("../CharacterModel/AnimationTree")
onready var inputBuffer = get_node("../InputBuffer")
#these will be loaded from playerdetails
var lightAttkPoints = 0
var heavyAttkPoints = 0

var lightWaitTime = .7
var heavyWaitTime = 1

var lightAttkArr = ["lJab", "rJab", "r_l_f_straightPunch"] #will be loaded from details later
var heavyAttkArr = ["lFrontKick"]
var lightAirArr = ["elbow_r_aerial"] #will be loaded from details later
var heavyAirArr = []
#these will be loaded from playerdetails

var YN = Globals.YN

func _ready():
	animationPlayer.get_animation("walk").set_loop(true)
	animationPlayer.get_animation("Idle").set_loop(true)
	animationPlayer.get_animation("run").set_loop(true)
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
	var animNode = animationTree.tree_root.get_node("lightAttack")

	if type == "light_attack":
		if animationTree.get("parameters/onGround/current") == YN.NO:
			animationTree.tree_root.get_node("airAction_attack").set_animation("r_l_aerialElbow")
			animationTree.set("parameters/isAirAction/current", YN.YES)
			GameServer.send_attack("r_l_aerialElbow")
		else:
			animNode.set_animation("lJab")
			animationTree.set("parameters/action/blend_amount", 0)
			lightAttkPoints = lightAttkPoints % (lightAttkArr.size())
			timer.wait_time = lightWaitTime
			if lightAttkPoints == 0:
				GameServer.send_attack(lightAttkArr[lightAttkPoints])
#				play_anim(lightAttkArr[lightAttkPoints])
			elif lightAttkPoints != lightAttkArr.size() && animationPlayer.get_queue().size() == 0:
				GameServer.send_attack(lightAttkArr[lightAttkPoints])
#				animationPlayer.queue(lightAttkArr[lightAttkPoints])
			lightAttkPoints = lightAttkPoints + 1
			animationTree.set("parameters/isAction/current", YN.YES)
		animationTree.set("parameters/actionType/current", Globals.ActionState.ATTACK)
	elif type == "heavy_attack":
		if animationTree.get("parameters/onGround/current") == YN.NO:
			animationTree.tree_root.get_node("airAction_attack").set_animation("flyingKick")
			animationTree.set("parameters/isAirAction/current", YN.YES)
			GameServer.send_attack("flyingKick")
		else:
			animNode.set_animation("lFrontKick")
			heavyAttkPoints = heavyAttkPoints % (heavyAttkArr.size())
			timer.wait_time = heavyWaitTime
			if heavyAttkPoints == 0:
#				play_anim(heavyAttkArr[heavyAttkPoints])
				pass
			elif heavyAttkPoints != heavyAttkArr.size() && animationPlayer.get_queue().size() == 0:
#				animationPlayer.queue(heavyAttkArr[heavyAttkPoints])
				pass
			heavyAttkPoints = heavyAttkPoints + 1
			animationTree.set("parameters/isAction/current", YN.YES)
		animationTree.set("parameters/actionType/current", Globals.ActionState.ATTACK)
		
func handle_block_animation():
	play_anim("RaiseBlock")
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	animationPlayer.clear_queue()
	play_anim("LightDamage")
	pass

func timer_timeout():
#	set_to_idle()
	lightAttkPoints = 0
	heavyAttkPoints = 0
	inputBuffer.purge()
	timer.stop()
	
func play_anim(name):
	if animationPlayer.current_animation != null and animationPlayer.current_animation == name:
		return
	animationPlayer.play(name)

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
