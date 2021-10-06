extends Node

class_name AnimationHandler

onready var anim = get_node("../AnimationPlayer")
onready var timer = get_node("../Timer")
onready var charDet = get_node("../CharacterDetails")
onready var animTree = get_node("../AnimationTree")
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
enum BinaryState {
	YES = 0,
	NO = 1,
}

enum ActionTransition {
	ATTACK = 0,
	DAMAGE = 1,
}

func _ready():
	anim.get_animation("walking").set_loop(true)
	anim.get_animation("idle").set_loop(true)
	anim.get_animation("running").set_loop(true)
	animTree.active = true

func handle_aerial_movement_animation(grounded, moveVec, justJumped):
	if justJumped:
		animTree.set("parameters/jump-fall/current", 0)
		animTree.set("parameters/onGround/current", BinaryState.NO) #only takes ints lol...
	elif charDet.geoState.get_currState() == 1 and charDet.actionState.get_currState() == 0 and grounded: #landing anim
		#TODO Fix later not urgent
		animTree.set("parameters/actionType/current", 2)
		animTree.set("parameters/isAction/current", BinaryState.YES)
	elif grounded:
		animTree.set("parameters/onGround/current", BinaryState.YES)
		animTree.set("parameters/isAirAction/current", BinaryState.NO)
		if moveVec.x == 0 and moveVec.z == 0: #Idle
			set_to_idle()
		elif inputBuffer.is_run_input() or animTree.get("parameters/movement/blend_amount") == 1: #run
			timer.start()
			animTree.set("parameters/movement/blend_amount", 1)
		else:
			timer.start()
			animTree.set("parameters/movement/blend_amount", 0) #walk
	else: #falling
		animTree.set("parameters/jump-fall/current", 1)
		animTree.set("parameters/isAction/current", BinaryState.NO)
		animTree.set("parameters/onGround/current", BinaryState.NO)
	
func handle_attack_animation(type):
	var animNode = animTree.tree_root.get_node("lightAttack")

	if type == "light_attack":
		if animTree.get("parameters/onGround/current") == BinaryState.NO:
			animTree.set("parameters/isAirAction/current", BinaryState.YES)
			print("here")
			var velocity = animTree.get_root_motion_transform().origin * 300
			get_node("../../characterModel").move_and_slide(velocity, Vector3.UP) #TODO move with animation
		else:
			animTree.set("parameters/action/blend_amount", 0)
			lightAttkPoints = lightAttkPoints % (lightAttkArr.size())
			timer.wait_time = lightWaitTime
			if lightAttkPoints == 0:
				#Server.send_attack(lightAttkArr[lightAttkPoints])
#				play_anim(lightAttkArr[lightAttkPoints])
				pass
			elif lightAttkPoints != lightAttkArr.size() && anim.get_queue().size() == 0:
				#Server.send_attack(lightAttkArr[lightAttkPoints])
#				anim.queue(lightAttkArr[lightAttkPoints])
				pass
			animTree.set("parameters/isAction/current", BinaryState.YES)
			lightAttkPoints = lightAttkPoints + 1
	elif type == "heavy_attack":
		if charDet.geoState.get_currState() == charDet.geoState.get_states()["AIR"]:
			pass
		else:
			heavyAttkPoints = heavyAttkPoints % (heavyAttkArr.size())
			timer.wait_time = heavyWaitTime
			if heavyAttkPoints == 0:
				play_anim(heavyAttkArr[heavyAttkPoints])
			elif heavyAttkPoints != heavyAttkArr.size() && anim.get_queue().size() == 0:
				anim.queue(heavyAttkArr[heavyAttkPoints])
			heavyAttkPoints = heavyAttkPoints + 1

func handle_block_animation():
	play_anim("RaiseBlock")
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	anim.clear_queue()
	play_anim("LightDamage")
	pass

func timer_timeout():
	set_to_idle()
	lightAttkPoints = 0
	heavyAttkPoints = 0
	inputBuffer.purge()
	timer.stop()
	
func play_anim(name):
	if anim.current_animation != null and anim.current_animation == name:
		return
	anim.play(name)
	
func set_to_idle():
	animTree.set("parameters/movement/blend_amount", -1);

func on_hit(damage):
	anim.play("lightDamage")

func _on_headHB_body_entered(body):
	pass # Replace with function body.


func _on_torsoHB_body_entered(body):
	pass # Replace with function body.


func _on_lHandHB_body_entered(body):
	if charDet.actionState.get_currState() == 2:
		if body.is_in_group("OtherPlayers") or body.is_in_group("Enemies"):
			print("hit")
			#Server.send_character_hit(body.name, get_node("../rig/Skeleton/leftHandBone").global_transform.origin, body.transform.origin)

func _on_rHandHB_body_entered(body):
	if charDet.actionState.get_currState() == 2:
		if body.is_in_group("OtherPlayers") or body.is_in_group("Enemies"):
			#Server.send_character_hit(get_parent().transform.origin, get_node("../rig/Skeleton/rightHandBone").global_transform.origin, body.transform.origin)
			pass
