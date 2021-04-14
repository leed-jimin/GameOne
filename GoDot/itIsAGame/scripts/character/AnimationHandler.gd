class_name AnimationHandler

var anim
var lightAttkPoints = 2
var heavyAttkPoints = 1
var lightAttkArr = ["lJab", "rJab"]
var heavyAttkArr = ["lFrontKick"]

func _init(anim):
	self.anim = anim
	anim.play("Idle")

func _ready():
	anim.get_animation("Walking").set_loop(true)
	anim.get_animation("Idle").set_loop(true)
	anim.get_animation("Running").set_loop(true)

func handle_movement_animation(kinBody, just_jumped, grounded, move_vec, charState, characterState):
	if just_jumped:
		play_anim("JumpUp")
		charState = characterState.AIRBOURNE
	elif charState == characterState.AIRBOURNE and kinBody.is_on_floor():
		play_anim("FallDown")
		yield(anim, "animation_finished")
		charState = characterState.IDLE
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			play_anim("Idle")
		else:
			play_anim("Walking")
			
	return charState
	
func handle_attack_animation(type):
	if type == "light_attack":
		lightAttkPoints = get_next_attack("light", lightAttkPoints)
	elif type == "heavy_attack":
		heavyAttkPoints = get_next_attack("heavy", heavyAttkPoints)
		
func get_next_attack(type, points):
	match points:
		3:
	
func handle_specials_animation():
	pass
	
func handle_knockback_animation():
	pass

func play_anim(name):
	if anim.current_animation != null and anim.current_animation == name:
		return
	anim.play(name)
