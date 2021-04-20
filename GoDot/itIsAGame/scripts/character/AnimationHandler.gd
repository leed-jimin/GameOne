class_name AnimationHandler

var anim
var tree
var playerDetails
var timer

var lightAttkPoints = 0
var heavyAttkPoints = 0
var lightWaitTime = .7
var heavyWaitTime = 1
var lightAttkArr = ["lJab", "rJab", "r_l_f_straightPunch"] #will be loaded from details later
var heavyAttkArr = ["lFrontKick"]
var airbourne = false


func _init(animPlayer, animTree, playerDet, timerNode):
	playerDetails = playerDet
	tree = animTree
	anim = animPlayer
	timer = timerNode
	tree.active = true
	tree.set("parameters/Ground_Move/current", 3)

func _ready():
	anim.get_animation("Walking").set_loop(true)
	anim.get_animation("Idle").set_loop(true)
	anim.get_animation("Running").set_loop(true)

func handle_aerial_movement_animation(just_jumped, grounded, moveVec):
	if just_jumped:
		tree.set("parameters/Air_Move/current", 0)
		tree.set("parameters/state/current", 1)
		playerDetails.geoStates.set_currState("AIR")
	elif tree.get("parameters/state/current") == 1 and grounded:
		tree.active = false
		tree.set("parameters/state/current", 0)
		play_anim("FallDown")
	elif grounded:
		playerDetails.geoStates.set_currState("GROUND")
		tree.set("parameters/state/current", 0)
		if moveVec.x == 0 and moveVec.z == 0:
			tree.set("parameters/Ground_Move/current", 3)
		else:
			tree.set("parameters/Ground_Move/current", 1)
	
func handle_attack_animation(type):
	playerDetails.actionStates.set_currState("BUSY")
	tree.active = false
	if type == "light_attack":
		if playerDetails.geoStates.get_currState() == playerDetails.geoStates.get_states()["AIR"]:
			play_anim("r_l_aerialElbow")
		else:
			lightAttkPoints = lightAttkPoints % (lightAttkArr.size())
			timer.wait_time = lightWaitTime
			timer.start()
			if lightAttkPoints != lightAttkArr.size():
				anim.queue(lightAttkArr[lightAttkPoints])
			lightAttkPoints = lightAttkPoints + 1
	elif type == "heavy_attack":
		if playerDetails.geoStates.get_currState() == playerDetails.geoStates.get_states()["AIR"]:
			pass
		else:
			heavyAttkPoints = heavyAttkPoints % (heavyAttkArr.size())
			timer.wait_time = heavyWaitTime
			timer.start()
			anim.queue(heavyAttkArr[heavyAttkPoints])
			heavyAttkPoints = heavyAttkPoints + 1
			if heavyAttkPoints == heavyAttkPoints.size():
				anim.clear_queue()
	
	#playerDetails.set_currCharState(charStates["IDLE"])
	
func handle_block_animation():
	pass
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	anim.clear_queue()
	pass

func timer_timeout():
	print("here")
	lightAttkPoints = 0
	heavyAttkPoints = 0
	timer.stop()
	
func play_anim(name):
	if anim.current_animation != null and anim.current_animation == name:
		return
	anim.play(name)
	
func set_to_idle():
	tree.set("parameters/state/current", 0)
	tree.set("parameters/Ground_Move/current", 3)
	tree.active = true
	playerDetails.geoStates.set_currState("GROUND")
	
