extends AnimationTree

const YN = Globals.YN
const ACTION = Globals.ActionState

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
	return get("parameters/isAction/current") == ACTION.ATTACK and get("parameters/actionType/current") == YN.YES

func is_attacking_air():
	return get("parameters/isAirAction/current") == ACTION.ATTACK and get("parameters/actionType/current") == YN.YES

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
	
