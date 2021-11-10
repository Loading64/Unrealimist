extends Label
onready var player = get_parent().get_parent()
enum weapon_state {MELEE,REVOLVER,SHOTGUN,RIFLE,EXPLOSIVE,LONG_RANGE}
var magazine_ammo_display = 0
var max_ammo_amount = 0
var now := OS.get_ticks_msec()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(_delta: float) -> void:
	var weapon = player.weapon
	match(weapon):
		weapon_state.REVOLVER:
			magazine_ammo_display = get_parent().get_parent().ammo_in_weapon_revolver
			max_ammo_amount = get_parent().get_parent().spare_ammo_revolver
		weapon_state.SHOTGUN:
			magazine_ammo_display = get_parent().get_parent().ammo_in_weapon_sg
			max_ammo_amount = get_parent().get_parent().spare_ammo_sg
	# Remove frames older than 1 second in the `ammo` array


	# Display FPS in the label
	text = str(magazine_ammo_display)+"/"+str(max_ammo_amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
