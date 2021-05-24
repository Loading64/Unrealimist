extends Spatial

export var fire_rate = 1
export var clip_size = 20
export var reload_rate = 3

var current_ammo = clip_size
var can_fire = true
func _process(delta):
	if Input.is_action_just_pressed("Primary_fire") and can_fire:
		#fire weapon
		print("Fired Weapon")
