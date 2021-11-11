extends KinematicBody
var enemy_health = 150
var ragdoll = 0
func _ragdoll():
	print("ragdollactivate")

func _process(delta):
	if enemy_health <= 0:
		_ragdoll()


