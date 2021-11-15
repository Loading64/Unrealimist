extends KinematicBody
var enemy_health = 150
var ragdoll = false
var collision_deleted = false
func _ragdoll():
	return ragdoll
func _enemy_health():
	return enemy_health
func _process(delta):
	if enemy_health <= 0 and collision_deleted == false:
		ragdoll = true
		if $CollisionShape:
			$CollisionShape.queue_free()
			collision_deleted == true
		else:
			pass
