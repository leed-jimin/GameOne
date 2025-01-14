extends Node

class_name CharacterDetails

@onready var animationTree = get_node("../CharacterModel/AnimationTree")
var attackTypes = Globals.AttackTypes

var actionsDict = {}

func _ready():
	get_attack_patterns()
	#get the attacks from user somehow

func get_attack_patterns():
#	for attack in attackTypes:
#		actionsDict[attackTypes[attack]] =  
	get_light_attacks()
	get_heavy_attacks()
	animationTree.load_attack_animation_nodes(actionsDict)
	
func get_light_attacks():
	actionsDict[attackTypes.LIGHT] = {}
	actionsDict[attackTypes.LIGHT][Globals.GROUND] = ["rJab", "lJab", "r_h_straightPunch"]
	actionsDict[attackTypes.LIGHT][Globals.AIR] = ["r_l_aerialElbow"]
	
func get_heavy_attacks():
	actionsDict[attackTypes.HEAVY] = {}
	actionsDict[attackTypes.HEAVY][Globals.GROUND] = ["lJab", "lFrontKick"]
	actionsDict[attackTypes.HEAVY][Globals.AIR] = ["flyingKick"]
	
func get_special_actions():
	actionsDict[attackTypes.SPECIAL] = {Globals.GROUND: [""]}
	actionsDict[attackTypes.SPECIAL] = {Globals.AIR: [""]}
	
func get_character_stats():
	pass
