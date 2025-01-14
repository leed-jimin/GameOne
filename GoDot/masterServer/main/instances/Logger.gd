extends Node

const logFormatString = "{time}-GATEWAY[{type}]: {msg}\n"
@onready var logger = load("res://main/instances/Logger.tscn")
var logText

func _ready():
	add_child(logger.instantiate())
	logText = get_node("/root/Logger/Logger")

func DEBUG(msg):
	logText.append_text(logFormatString.format({"time": get_date_iso(), "type": "DEBUG", "msg": msg}))

func ERROR(msg):
	logText.append_text(logFormatString.format({"time": get_date_iso(), "type": "ERROR", "msg": msg}))

func WARN(msg):
	logText.append_text(logFormatString.format({"time": get_date_iso(), "type": "WARN", "msg": msg}))

func INFO(msg):
	logText.append_text(logFormatString.format({"time": get_date_iso(), "type": "INFO", "msg": msg}))

func get_date_iso():
	var date = Time.get_datetime_dict_from_system()
	return "{yyyy}-{mm}-{dd}T{hh}:{mi}Z".format({"yyyy": date["year"], "mm": date["month"], "dd": date["day"], "hh": date["hour"], "mi": date["minute"]})
