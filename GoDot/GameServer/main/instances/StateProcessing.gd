extends Node

var worldState
#Enemies if any
var enemyIdCounter = 1
var enemyMaximum = 2
var enemyTypes = ["EnemyModel"]
var enemySpawnPoints = [Vector3(20, 20, 20), Vector3(0, 20, 20), Vector3(20, 20, 0)]
var enemyList = {}

#Players if any
var playerIdCounter = 1
var playerMaximum = 2
var playerTypes = ["EnemyModel"]
var playerSpawnPoints = [Vector3(30, 20, 20), Vector3(0, 20, 30), Vector3(20, 20, 10)]
var playerList = {}

var playerStateCollection = {}

var openLocations = [0,1,2]
var occupiedLocations = {}

func _physics_process(delta):
	if not playerStateCollection.empty():
		worldState = playerStateCollection.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
#		worldState["Enem"] = enemyList
		
		#verification
		#Anti-cheat
		#cuts
		#physics check
		#anything else
		get_node("/root/GameServer").send_world_state(worldState)

func spawn_enemy():
	if enemyList.size() < enemyMaximum:
		randomize()
		var type = enemyTypes[randi() % enemyTypes.size()]
		var rngLocationIndex = randi() % openLocations.size()
		var location = enemySpawnPoints[openLocations[rngLocationIndex]]
		occupiedLocations[enemyIdCounter] = openLocations[rngLocationIndex]
		openLocations.remove(rngLocationIndex)
		enemyList[enemyIdCounter] = {"Type": type, "Location": location, "Health": 200, "State": "Idle", "time_out": 1}
		enemyIdCounter += 1
		
	for enemy in enemyList.keys():
		if enemyList[enemy]["State"] == "Dead":
			if enemyList[enemy]["time_out"] == 0:
				enemyList.erase(enemy)
			else:
				enemyList[enemy]["time_out"] = enemyList[enemy]["time_out"] - 1

func npc_hit(enemyId, damage):
	if enemyList[enemyId]["Health"] <= 0:
		pass
	else:
		enemyList[enemyId]["Health"] = enemyList[enemyId]["Health"] - damage
		if enemyList[enemyId]["Health"] <= 0:
			enemyList[enemyId]["State"] = "Dead"
			openLocations.append(occupiedLocations[enemyId])
			occupiedLocations.erase(enemyId)
			
func character_hit(playerId, attackPosition, receiverPosition):
	if not playerList.has(playerId):
		playerList[playerId] = {"Health": 200, "Energy": 100}
	if playerList[playerId]["Health"] <= 0:
		print("passing hit")
		pass
	elif compare_ground_vectors(attackPosition, receiverPosition):
		print("character hit")
		playerList[playerId]["Health"] = playerList[playerId]["Health"] - 10
		get_parent().send_receive_hit(int(playerId), 10)
		if playerList[playerId]["Health"] <= 0:
			print(playerList)
			print(playerId)
			playerList[playerId]["State"] = "Dead"
			openLocations.append(occupiedLocations[playerId])
			occupiedLocations.erase(playerId)
			
func compare_ground_vectors(v1, v2): 
	if (abs(v1.x - v2.x) < 3) and (abs(v1.z - v2.z) < 3):
		return true
	else:
		return false
