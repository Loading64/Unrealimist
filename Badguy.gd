extends KinematicBody
var enemy_health = 150

func _ready():
	pass # Replace with function body.
func _process(delta):
	if enemy_health <= 0:
		print("enemy dead")
		queue_free()
