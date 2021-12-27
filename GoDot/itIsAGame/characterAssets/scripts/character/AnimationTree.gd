extends AnimationTree


const YN = Globals.YN
const ACTION = Globals.ActionState
var AttackTypes = Globals.AttackTypes

#Checks for ground and air idling
func is_idle():
	return is_idle_ground() or is_idle_air()
	
func is_idle_ground():
	return get("parameters/isAction/current") == YN.NO and get("parameters/onGround/current") == YN.YES
	
func is_idle_air():
	return get("parameters/onGround/current") == YN.NO and get("parameters/isAirAction/current") == YN.NO

func is_attacking():
	return is_attacking_ground() or is_attacking_air()

func is_attacking_ground():
	return get("parameters/isAction/current") == YN.YES and get("parameters/actionType/current") == ACTION.ATTACK

func set_action_ground(action = ACTION.ACTION):
	set("parameters/isAction/current", YN.YES)
	set("parameters/actionType/current", action)

func is_attacking_air():
	return get("parameters/isAirAction/current") == YN.YES and get("parameters/airActionType/current") == ACTION.ATTACK

func set_action_air(action = ACTION.ACTION):
	set("parameters/isAirAction/current", YN.YES) 
	set("parameters/airActionType/current", action)

func is_on_ground():
	return get("parameters/onGround/current") == YN.YES
	
func is_in_air():
	return get("parameters/onGround/current") == YN.NO

func set_idle():
	set("parameters/movement/blend_amount", -1)

func set_walk():
	set("parameters/movement/blend_amount", 0)

func set_run():
	set("parameters/movement/blend_amount", 1)

#setting up attacks
func load_attack_animation_nodes(actionsDict):
	for attack in actionsDict:
		var attackEntry = actionsDict[attack]
		match attack:
			AttackTypes.LIGHT, AttackTypes.HEAVY, AttackTypes.SPECIAL:
				set_animation_nodes_for_type(attack + Globals.GROUND, attackEntry[Globals.GROUND])
				set_animation_nodes_for_type(attack + Globals.AIR, attackEntry[Globals.AIR])
				break
			AttackTypes.SPECIAL_LIGHT, AttackTypes.SPECIAL_HEAVY, AttackTypes.DASH:
				set_animation_nodes_for_type(attack + Globals.GROUND, attackEntry[Globals.GROUND])
				break
	
func set_animation_nodes_for_type(type, animationsArr):
	var index = 0
	for attack in animationsArr:
		tree_root.get_node(type + str(index)).set_animation(animationsArr[index])
		index+=1
