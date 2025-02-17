extends Node

const logFormatString = "{time}-CLIENT[{type}]: {msg}"


func DEBUG(msg):
	print(logFormatString.format({"time": get_date_iso(), "type": "DEBUG", "msg": msg}))

func ERROR(msg):
	print(logFormatString.format({"time": get_date_iso(), "type": "ERROR", "msg": msg}))

func WARN(msg):
	print(logFormatString.format({"time": get_date_iso(), "type": "WARN", "msg": msg}))

func INFO(msg):
	print(logFormatString.format({"time": get_date_iso(), "type": "INFO", "msg": msg}))

func get_date_iso():
	var date = Time.get_datetime_dict_from_system()
	return "{yyyy}-{mm}-{dd}T{hh}:{mi}Z".format({"yyyy": date["year"], "mm": date["month"], "dd": date["day"], "hh": date["hour"], "mi": date["minute"]})
