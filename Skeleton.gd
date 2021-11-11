extends Skeleton



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_owner().get_owner()._ragdoll() == true:
		physical_bones_start_simulation()
