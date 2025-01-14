extends CharacterBody3D

var maxHp
var currentHp
var type
var state

func _ready():
	var percentageHp = int((float(currentHp) / maxHp) * 100)
	#healthBar.value = percentageHp
	if state == "Idle":
		get_node("AnimationPlayer").play("Idle")
	elif state == "Dead":
		get_node("AnimationPlayer").stop()
		#hide body (fade)

func move_enemy(newPosition, rotationVector):
	transform.origin = newPosition
	rotation_degrees = rotationVector
	
func health(health):
	if health != currentHp:
		currentHp = health
		health_bar_update()
		if currentHp <= 0:
			on_death()
	
func health_bar_update():
	pass
	
func on_hit(damage):
	MasterServer.npc_hit(int(get_name()), damage)
	
func on_death():
	get_node("CollisionShape3D").set_deferred("disabled", true)
	get_node("rig").hide()
	#death anim
	#healthbar hide()
	
