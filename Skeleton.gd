extends Skeleton



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_owner().get_owner()._ragdoll() == true: #call badguy script and check if hp => 0 if so activate the skeleton
		physical_bones_start_simulation()
		
	else:
		pass
		#print("ragdollnotactive")
