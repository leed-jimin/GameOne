extends KinematicBody


func move_player(newPosition):
	print(newPosition)
	transform.origin = newPosition
