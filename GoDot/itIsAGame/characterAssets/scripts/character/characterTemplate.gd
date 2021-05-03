extends KinematicBody


func move_player(newPosition):
	global_transform.origin = newPosition
