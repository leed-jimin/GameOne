class_name AnimationHandler

var anim
var charDet
var timer

#these will be loaded from playerdetails
var lightAttkPoints = 0
var heavyAttkPoints = 0

var lightWaitTime = .7
var heavyWaitTime = 1

var lightAttkArr = ["lJab", "rJab", "r_l_f_straightPunch"] #will be loaded from details later
var heavyAttkArr = ["lFrontKick"]
var lightAirArr = ["r_l_aerialElbow"] #will be loaded from details later
var heavyAirArr = []
#these will be loaded from playerdetails


func _init(animPlayer, characterDetails, timerNode):
	charDet = characterDetails
	anim = animPlayer
	timer = timerNode

func _ready():
	anim.get_animation("Walking").set_loop(true)
	anim.get_animation("Idle").set_loop(true)
	anim.get_animation("Running").set_loop(true)

func handle_aerial_movement_animation(just_jumped, grounded, moveVec):
	if charDet.geoState.get_currState() == 1:
		play_anim("JumpUp")
		#charDet.geoState.set_currState("AIR")
		return
	elif charDet.geoState.get_currState() == 1 and charDet.actionState.get_currState() == 0 and grounded:
		#TODO fix this i think
		#charDet.geoState.set_currState("GROUND")
		handle_ground_animation()
	elif grounded:
		#charDet.geoState.set_currState("GROUND")
		if moveVec.x == 0 and moveVec.z == 0:
			play_anim("Idle")
		else:
			play_anim("Walking")
	
func handle_attack_animation(type):
	charDet.actionState.set_currState("ATTACKING")
	print(charDet.geoState.get_currState())
	if type == "light_attack":
		Server.send_attack(lightAttkArr[0])
		if charDet.geoState.get_currState() == charDet.geoState.get_states()["AIR"]:
			timer.start()
			play_anim(lightAirArr[0])
		else:
			lightAttkPoints = lightAttkPoints % (lightAttkArr.size())
			timer.wait_time = lightWaitTime
			timer.start()
			if lightAttkPoints == 0:
				play_anim(lightAttkArr[lightAttkPoints])
			elif lightAttkPoints != lightAttkArr.size() && anim.get_queue().size() == 0:
				anim.queue(lightAttkArr[lightAttkPoints])
			lightAttkPoints = lightAttkPoints + 1
	elif type == "heavy_attack":
		if charDet.geoState.get_currState() == charDet.geoState.get_states()["AIR"]:
			pass
		else:
			heavyAttkPoints = heavyAttkPoints % (heavyAttkArr.size())
			timer.wait_time = heavyWaitTime
			timer.start()
			if heavyAttkPoints == 0:
				play_anim(heavyAttkArr[heavyAttkPoints])
			elif heavyAttkPoints != heavyAttkArr.size() && anim.get_queue().size() == 0:
				anim.queue(heavyAttkArr[heavyAttkPoints])
			heavyAttkPoints = heavyAttkPoints + 1

func handle_ground_animation():
	if charDet.actionState.get_currState() == 0:
		charDet.actionState.set_currState("BUSY")
		timer.wait_time = .4
		timer.start()
		play_anim("FallDown")

func handle_block_animation():
	pass
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	anim.clear_queue()
	pass

func timer_timeout():
	set_to_idle()
	lightAttkPoints = 0
	heavyAttkPoints = 0
	timer.stop()
	
func play_anim(name):
	if anim.current_animation != null and anim.current_animation == name:
		return
	anim.play(name)
	
func set_to_idle():
	if charDet.geoState.get_currState() == 0: #ground
		play_anim("Idle")
	elif charDet.geoState.get_currState() == 1:
		play_anim("JumpUp")
	charDet.actionState.set_currState("NONE")
	
