class_name States

var states
var currState
var defaultState

func _init(statesDict: Dictionary, defaultState: String):
	states = statesDict
	defaultState = statesDict[defaultState]
	set_defaults()
	
	
func set_defaults():
	currState = defaultState

func get_currState():
	return currState
	
func set_currState(state):
	if typeof(state) == TYPE_STRING:
		currState = state
	else:
		currState = state
	
func get_states():
	return states
