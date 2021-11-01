extends Node

#constants
const GROUND = "ground"
const AIR = "air"

#enums
enum YN {
	YES = 0,
	NO = 1,
}

enum ActionState {
	ATTACK = 0,
	ACTION = 1,
	DAMAGE = 2,
	DEAD = 3,
}
