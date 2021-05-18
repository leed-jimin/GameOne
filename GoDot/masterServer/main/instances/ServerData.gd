extends Node

var skillData
var testData = {
	"Items": {
		"Strength": 12,
		"Jump": 30,
	},
	"Accessories": [
		"AntlerClaw"
	],
	"Classes": {
		"Fighter": 3,
		"Scout": 2,
	}
}

#func _ready():
#	var skillDataFile = File.new()
#	skillDataFile.open("res://Data/test.json", File.READ)
#	var json = JSON.parse(skillDataFile.get_as_text())
#	skillDataFile.close()
#	skillData = json.result
