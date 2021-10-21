extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(_delta: float) -> void:

	var magazine_ammo_display = get_parent().get_parent().magazine_ammo
	var max_ammo_amount = get_parent().get_parent().ammo_capacity
	var now := OS.get_ticks_msec()

	# Remove frames older than 1 second in the `ammo` array


	# Display FPS in the label
	text = str(magazine_ammo_display)+"/"+str(max_ammo_amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
