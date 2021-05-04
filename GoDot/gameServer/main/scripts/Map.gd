extends Node

var enemyIdCounter = 1
var enemyMaximum = 2
var enemyTypes = ["EnemyModel"]
var enemySpawnPoints = [Vector3(20, 20, 20), Vector3(0, 20, 20), Vector3(20, 20, 0)]
var openLocations = [0,1,2]
var occupiedLocations = {}
var enemyList = {}

func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	#timer.connect("timeout", self, "spawn_enemy")
	self.add_child(timer)
	
func spawn_enemy():
	if enemyList.size() < enemyMaximum:
		randomize()
		var type = enemyTypes[randi() % enemyTypes.size()]
		var rngLocationIndex = randi() % openLocations.size()
		var location = enemySpawnPoints[openLocations[rngLocationIndex]]
		occupiedLocations[enemyIdCounter] = openLocations[rngLocationIndex]
		openLocations.remove(rngLocationIndex)
		enemyList[enemyIdCounter] = {"EnemyType": type, "EnemyLocation": location, "EnemyMaxHealth": 200, "EnemyHealth": 200, "EnemyState": "Idle", "time_out": 1}
		enemyIdCounter += 1
		
	for enemy in enemyList.keys():
		if enemyList[enemy]["EnemyState"] == "Dead":
			if enemyList[enemy]["time_out"] == 0:
				enemyList.erase(enemy)
			else:
				enemyList[enemy]["time_out"] = enemyList[enemy]["time_out"] - 1
				
func npc_hit(enemyId, damage):
	if enemyList[enemyId]["EnemyHealth"] <= 0:
		pass
	else:
		enemyList[enemyId]["EnemyHealth"] = enemyList[enemyId]["EnemyHealth"] - damage
		if enemyList[enemyId]["EnemyHealth"] <= 0:
			print(enemyList)
			print(enemyId)
			enemyList[enemyId]["EnemyState"] = "Dead"
			openLocations.append(occupiedLocations[enemyId])
			occupiedLocations.erase(enemyId)
			
