extends Node

#constants
const GROUND = "Ground"
const AIR = "Air"

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

const AttackTypes = {
	LIGHT = "light",
	HEAVY = "heavy",
	SPECIAL = "special",
	SPECIAL_LIGHT = "spLight",
	SPECIAL_HEAVY = "spHeavy",
	DASH = "dash"
}
