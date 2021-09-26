extends Node

class_name InputBuffer

var buffer
const MAX_INPUTS = 5

enum InputType {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	JUMP,
	LIGHT,
	HEAVY,
	TARGET,
}

func _ready():
	buffer = []
	
func insert(type):
	if buffer.size() >= MAX_INPUTS:
		buffer.pop_front()
	
	buffer.append(type)
	print(buffer)
	
func get_last_inputs(number = 1):
	var size = buffer.size()
	return buffer.slice(size - number, size)

func purge():
	buffer = []
	
func is_run_input():
	if buffer.size() > 1:
		if buffer[-1] == buffer[-2]:
			return true
			
	return false
