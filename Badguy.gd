extends KinematicBody
var enemy_health = 150
var ragdoll = false
onready var player = get_owner().get_node("KinematicBody")
func _ragdoll():
	return ragdoll

func _process(delta):
	if enemy_health <= 0:
		ragdoll = true
		if $CollisionShape:
			$CollisionShape.queue_free()
