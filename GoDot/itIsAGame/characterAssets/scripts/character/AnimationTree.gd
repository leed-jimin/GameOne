extends AnimationTree


const YN = Globals.YN
const ACTION = Globals.ActionState
var AttackTypes = Globals.AttackTypes
var AttackIndexes = Globals.AttackIndexes

#Checks for ground and air idling
func is_idle():
	return is_idle_ground() or is_idle_air()
	
func is_idle_ground():
	return get("parameters/isActionGround/current") == YN.NO and get("parameters/onGround/current") == YN.YES
	
func is_idle_air():
	return get("parameters/onGround/current") == YN.NO and get("parameters/isActionAir/current") == YN.NO

func is_attacking():
	return is_attacking_ground() or is_attacking_air()

func is_attacking_ground():
	return get("parameters/isActionGround/current") == YN.YES and get("parameters/actionTypeGround/current") == ACTION.ATTACK

func set_action_ground(action = ACTION.ACTION):
	set("parameters/isActionGround/current", YN.YES)
	set("parameters/actionTypeGround/current", action)

func is_attacking_air():
	return get("parameters/isActionAir/current") == YN.YES and get("parameters/actionTypeAir/current") == ACTION.ATTACK

func set_action_air(action = ACTION.ACTION):
	set("parameters/isActionAir/current", YN.YES) 
	set("parameters/actionTypeAir/current", action)

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
				continue
			AttackTypes.SPECIAL_LIGHT, AttackTypes.SPECIAL_HEAVY, AttackTypes.DASH:
				set_animation_nodes_for_type(attack + Globals.GROUND, attackEntry[Globals.GROUND])
				continue
	
func set_animation_nodes_for_type(type, animationsArr):
	var index = 0
	for attack in animationsArr:
		tree_root.get_node(type + str(index)).set_animation(animationsArr[index])
		index+=1

func set_attack(type, elevationState):
	var nodeName = type + elevationState
	var attackNodeIndex = get("parameters/{0}/current".format({"0": nodeName}))
	#2. next attack(s)
	if is_attacking():
		if (tree_root.get_node(nodeName + str(attackNodeIndex + 1)) == null):
			set("parameters/{0}/current".format({"0": nodeName}), 0)
		else:
			tree_root.get_node(nodeName).set_input_as_auto_advance(attackNodeIndex, true)
	#1. first attack
	else:
		reset_transition_advances(nodeName)
		set("parameters/{0}/current".format({"0": nodeName}), 0)
		set("parameters/attack{0}/current".format({"0": elevationState}), AttackIndexes[type])
		if (elevationState == Globals.GROUND):
			set_action_ground(ACTION.ATTACK)
		else:
			set_action_air(ACTION.ATTACK)
	#1a. timeout and reset
	#3. final attack; reset
	
func reset_transition_advances(nodeName):
	var index = 0
	while tree_root.get_node(nodeName + str(index)) != null: #errors have to fix
		tree_root.get_node(nodeName).set_input_as_auto_advance(index, false)
		index += 1
	
