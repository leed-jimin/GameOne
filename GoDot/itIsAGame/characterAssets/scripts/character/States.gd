class_name States

var states
var currState = 0
var defaultState = 0

func _init(statesDict: Dictionary, defaultStateStr: String):
	states = statesDict
	defaultState = statesDict[defaultStateStr]
	
func set_defaults():
	currState = defaultState

func get_currState():
	return currState
	
func set_currState(state):
	if typeof(state) == TYPE_STRING:
		currState = states[state]
	elif typeof(state) == TYPE_INT:
		currState = state
	else:
		print("Error - set_currState on: {0}".format({"0": state}))
	
func get_state_value(state):
	if typeof(state) == TYPE_STRING:
		return states[state]
	else:
		print("Error - get_state_value on: {0}".format({"0": state}))


func get_states():
	return states
