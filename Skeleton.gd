extends Skeleton

onready var player = get_owner().get_owner().get_owner().get_node("KinematicBody")
onready var direction = get_owner().get_owner().transform.origin - player.transform.origin
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_owner().get_owner()._ragdoll() == true: #call badguy script and check if hp => 0 if so activate the skeleton
		var direction = get_owner().get_owner().transform.origin - player.transform.origin
		physical_bones_start_simulation()
		for child in get_children():
			if child.get_class() == 'PhysicalBone':
				child.apply_central_impulse((direction))
#child.apply_central_impulse((direction) * get_owner().get_owner()._enemy_health())
