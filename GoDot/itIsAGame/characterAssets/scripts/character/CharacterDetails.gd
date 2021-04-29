var States = load("res://characterAssets/scripts/character/States.gd") # Relative path

class_name CharacterDetails


const geoStates = {
	"GROUND": 0,
	"AIR": 1,
}

const actionStates = {
	"NONE": 0,
	"BUSY": 1,
	"ATTACKING": 2
}

const hurtStates = {
	"NONE": 0,
	"LIGHT": 1,
	"HEAVY": 2,
	"DEAD": 3
}

var geoState
var actionState
var hurtState

func _init():
	geoState = States.new(geoStates, "GROUND")
	actionState = States.new(actionStates, "NONE")
	hurtState = States.new(hurtStates, "NONE")
	set_states_defaults()

func set_states_defaults():
	geoState.set_defaults()
	actionState.set_defaults()
	hurtState.set_defaults()
	
func get_attack_patterns():
	pass
	
func get_light_attacks():
	pass
	
func get_heavy_attacks():
	pass
	
func get_special_actions():
	pass
	
func get_character_stats():
	pass
