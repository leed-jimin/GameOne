extends Node

var playerStats = preload("res://main/userDetails/PlayerStats.tscn")
var playerScene = preload("res://characterAssets/scenes/Player.tscn")
var characterTemplate = preload("res://characterAssets/scenes/CharacterTemplate.tscn")

var lastWorldState = 0
var worldStateBuffer = [] #worldStateBuffer = [pastpast WS, past WS, future WS, FutureFuture WS]
const interpolationOffset = 100

func _ready():
	spawn_user_player() # this is for testing animations
	
func spawn_user_player():
	var model = playerScene.instantiate()
	model.transform.origin = Vector3(0, 10, 0)
	add_child(model)
	$Camera3D.set_target(model.get_node("CameraLocation"))

func spawn_new_player(playerId, spawnPosition):
	if not get_tree().get_unique_id() == playerId:
		if not get_node("Node2D/OtherPlayers").has_node(str(playerId)):
			var newPlayer = characterTemplate.instantiate()
			newPlayer.transform.origin = spawnPosition # might not work
			newPlayer.name = str(playerId)
			get_node("Node2D/OtherPlayers").add_child(newPlayer)

func spawn_new_enemy(enemyId, enemyDict):
	var newEnemy = characterTemplate.instantiate()
	newEnemy.transform.origin = enemyDict["Location"]
	newEnemy.currentHp = enemyDict["Health"]
	newEnemy.type = enemyDict["Type"]
	newEnemy.state = enemyDict["State"]
	newEnemy.name = str(enemyId)
	get_node("Node2D/Enemies").add_child(newEnemy, true)

func despawn_player(playerId):
	await get_tree().create_timer(0.2).timeout
	get_node("Node2D/OtherPlayers/" + str(playerId)).queue_free()

func update_world_state(worldState):
	if worldState["T"] > lastWorldState:
		lastWorldState = worldState["T"]
		worldStateBuffer.append(worldState)
		
func _physics_process(delta):
	var renderTime = GameServer.clientClock - interpolationOffset
	if worldStateBuffer.size() > 1:
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[2]["T"]:
			worldStateBuffer.remove(0)
		if worldStateBuffer.size() > 2:
			var interpolationFactor = float(renderTime - worldStateBuffer[1]["T"]) / float(worldStateBuffer[2]["T"] - worldStateBuffer[1]["T"])
			for player in worldStateBuffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enem":
					continue
				if player == get_tree().get_unique_id():
					continue
				if not worldStateBuffer[1].has(player):
					continue
				if get_node("Node2D/OtherPlayers").has_node(str(player)):
					var newPosition = lerp(worldStateBuffer[1][player]["P"], worldStateBuffer[2][player]["P"], interpolationFactor)
					get_node("Node2D/OtherPlayers/" + str(player)).move_player(newPosition, worldStateBuffer[2][player]["R"], worldStateBuffer[2][player]["M"])
				else:
					print("spawning player")
					spawn_new_player(player, worldStateBuffer[2][player]["P"])
#			for enemy in worldStateBuffer[2]["Enem"].keys():
#				if not worldStateBuffer[1]["Enem"].has(enemy):
#					continue
#				if get_node("YSort/Enemies").has_node(str(enemy)):
#					var newPosition = lerp(worldStateBuffer[1]["Enem"][enemy]["Location"], worldStateBuffer[2]["Enem"][enemy]["Location"], interpolationFactor)
#					#var rotationVector = worldStateBuffer[2]["Enem"][enemy][""]
#					get_node("YSort/Enemies/" + str(enemy)).move_enemy(newPosition)
#					get_node("YSort/Enemies/" + str(enemy)).health(worldStateBuffer[1]["Enem"][enemy]["Health"])
#				else:
#					spawn_new_enemy(enemy, worldStateBuffer[2]["Enem"][enemy])
		elif renderTime > worldStateBuffer[1].T:
			var extrapolationFactor = float(renderTime - worldStateBuffer[0]["T"]) / float(worldStateBuffer[1]["T"] - worldStateBuffer[0]["T"]) - 1.00
			for player in worldStateBuffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enem":
					continue
				if player == get_tree().get_unique_id():
					continue
				if not worldStateBuffer[0].has(player):
					continue
				if get_node("Node2D/OtherPlayers").has_node(str(player)):
					var positionDelta = (worldStateBuffer[1][player]["P"] - worldStateBuffer[0][player]["P"])
					var newPosition = worldStateBuffer[1][player]["P"] + (positionDelta * extrapolationFactor)
					var rotationVector = worldStateBuffer[1][player]["R"]
					get_node("Node2D/OtherPlayers/" + str(player)).move_player(newPosition, rotationVector)
