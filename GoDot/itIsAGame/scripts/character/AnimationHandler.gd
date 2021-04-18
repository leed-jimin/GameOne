class_name AnimationHandler

var anim
var timer
var lightAttkPoints = 0
var heavyAttkPoints = 0
var lightAttkArr = ["lJab", "rJab"] #will be loaded from details later
var heavyAttkArr = ["lFrontKick"]

func _init(animPlayer):
	anim = animPlayer
	timer = Timer.new()
	timer.wait_time = 1
	anim.play("Idle")

func _ready():
	anim.get_animation("Walking").set_loop(true)
	anim.get_animation("Idle").set_loop(true)
	anim.get_animation("Running").set_loop(true)

func handle_aerial_movement_animation():
	pass
	
func handle_attack_animation(type):
	if type == "light_attack":
		lightAttkPoints = lightAttkPoints % (lightAttkArr.size())
		if lightAttkPoints == 0:
			pass
		timer.start()
		play_anim(lightAttkArr[lightAttkPoints], true)
		lightAttkPoints = lightAttkPoints + 1
	elif type == "heavy_attack":
		print("heavy")
		heavyAttkPoints = heavyAttkPoints % (heavyAttkArr.size())
		if heavyAttkPoints == 0:
			pass
		timer.start()
		play_anim(heavyAttkArr[heavyAttkPoints], true)
		heavyAttkPoints = heavyAttkPoints + 1
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	pass

func play_anim(name, toYield):
	if anim.current_animation != null and anim.current_animation == name:
		return
	anim.play(name)
	if toYield:
		print("yeirld")
		yield(anim, "animation_finished")
