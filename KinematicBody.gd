extends KinematicBody
const MAX_CAM_SHAKE = 0.3
var wall_normal
var revolver_max_cylinder = 6
var reload = 0
var player_health = 80
var ammo_pickup
var magazine_ammo = 2
var revolver_cylinder = 6
var ammo_capacity = 150
var damage = 25
var spread = 15
var standing = false
var speed = 1
var standing_speed = 10
var crouch_speed = 2
var transition_speed = 20
var sliding_speed = 30
var sprinting_speed = 20
var wallrun_speed = 50
var h_acceleration = 8
var air_acceleration = 1
var normal_acceleration = 6
var default_height = 1
var crouching_height = 0.001
var sliding_height = 0.001
var gravity = 10
var jump = 9
var full_contact = false
var double_jump = 1
var mouse_sensitivity = 0.06
var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var sprinting = false
var sliding = false
var crouching = false
#cant be arsed making it elegant

var ammo_in_weapon_revolver = 6
var spare_ammo_revolver = 20
const AMMO_IN_MAG_revolver = 6

var ammo_in_weapon_sg = 2
var spare_ammo_sg = 10
const AMMO_IN_MAG_sg = 2

var ammo_in_weapon_rifle = 30
var spare_ammo_rifle = 150
const AMMO_IN_MAG_rifle = 30

onready var assualt_rifle = preload("res://Mas38.tscn")
onready var shotgun = preload("res://stolzersondoubledeuce.tscn")
onready var revolver = preload("res://Revolver.tscn")
onready var Longrangerifle = preload("res://LAR.tscn")
onready var Raycastnode = (RayCast)
onready var dashtimer = $DashTimer
onready var statetimer = $StateTimer
onready var timer = $Timer
onready var pcap = $CollisionShape
onready var head = $Head
onready var wall_check = $wallcheck
onready var ground_check = $GroundCheck
onready var Shotgunray_container = $"Head/HandLoc/doublebarrelshotgun/RayContainerShotgun"
onready var rifleray_container = $"Head/HandLoc/Mas38/RayContainerRifle"
onready var revolverray_container = $Head/HandLoc/Revolver/RayContainerRevolver
onready var hand = $Head/Hand
onready var handloc = $Head/HandLoc
onready var anim_player = $AnimationPlayer
onready var camera = $Head/Camera 
enum weapon_state {MELEE,REVOLVER,SHOTGUN,RIFLE,EXPLOSIVE,LONG_RANGE}
enum state  {SPRINTING, CROUCHING, STANDING, SLIDING, SHOOTING, DASHING}
var weapon = weapon_state.MELEE
var player_state = state.STANDING

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for r in Shotgunray_container.get_children():
		r.cast_to.x = rand_range(spread, -spread)
		r.cast_to.y = rand_range(spread, -spread)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#
func _wallrun():
	if Input.is_action_pressed("jump"):
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			if wall_check.is_colliding():
				wall_normal = get_slide_collision(0)
				gravity_vec = Vector3.ZERO
				speed = wallrun_speed
				double_jump = 1
				air_acceleration = 1
				#direction = -wall_normal.normal * speed
func _input(event):
	if event is InputEventMouseMotion and is_on_floor():
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	elif event is InputEventMouseMotion and is_on_floor() == false:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-360), deg2rad(360))

# warning-ignore:unused_argument
func update_weapon():
	$"Head/HandLoc/doublebarrelshotgun".visible = false
	$"Head/HandLoc/Revolver".visible = false
	$"Head/HandLoc/Mas38".visible = false
	$"Head/HandLoc/LAR".visible = false
	match(weapon):
		weapon_state.MELEE:
			print("Melee equipped")
			damage = 300
			$"Head/HandLoc/doublebarrelshotgun".visible = false
			$"Head/HandLoc/Revolver".visible = false
			$"Head/HandLoc/Mas38".visible = false
			$"Head/HandLoc/LAR".visible = false
		weapon_state.REVOLVER:
			print("Revolver equipped")
			damage = 200
			$Head/HandLoc/Revolver.visible = true
			spread = 20
			magazine_ammo = ammo_in_weapon_revolver
			ammo_capacity = spare_ammo_revolver
		weapon_state.SHOTGUN:
			print("Shotgun equipped")
			damage = 30
			$"Head/HandLoc/doublebarrelshotgun".visible = true
			spread = 3500
			magazine_ammo = ammo_in_weapon_sg
			ammo_capacity = spare_ammo_sg
		weapon_state.RIFLE:
			print("Rifle equipped")
			damage = 50
			$"Head/HandLoc/Mas38".visible = true
			spread = 40
			magazine_ammo = ammo_in_weapon_rifle
			ammo_capacity = spare_ammo_rifle
		weapon_state.EXPLOSIVE:
			print("Explosive equipped")
			damage = 70
		weapon_state.LONG_RANGE:
			print("Long Range equipped")
			damage = 500
			$"Head/HandLoc/LAR".visible = true
			
func _fire_shotgun():
	if Input.is_action_just_pressed("Primary_fire"):
		if not anim_player.is_playing() and ammo_in_weapon_sg != 0:
			for r in Shotgunray_container.get_children():
				r.cast_to.x = rand_range(spread,-spread)
				r.cast_to.y = rand_range(spread,-spread)
				if r.is_colliding():
					if r.get_collider().is_in_group("Enemy"):
						r.get_collider().enemy_health -= damage
						print("SGHIT")
			anim_player.play("ShotgunFire")
			magazine_ammo -= 1
			ammo_capacity -= 1
func _fire_rifle():
	if Input.is_action_pressed("Primary_fire") and ammo_in_weapon_rifle != 0:
		if not anim_player.is_playing():
			for r in rifleray_container.get_children():
				r.cast_to.x = rand_range(spread,-spread)
				r.cast_to.y = rand_range(spread,-spread)
				if r.is_colliding():
					if r.get_collider().is_in_group("Enemy"):
						r.get_collider().enemy_health -= damage
						print("Assualthit")
			anim_player.play("AssualtFire")
			magazine_ammo -= 1
			ammo_capacity -= 1
func _fire_revolver():
	if Input.is_action_pressed("Primary_fire") and ammo_in_weapon_revolver != 0:
		if not anim_player.is_playing():
			for r in revolverray_container.get_children():
				r.cast_to.x = rand_range(spread,-spread)
				r.cast_to.y = rand_range(spread,-spread)
				if r.is_colliding():
					if r.get_collider().is_in_group("Enemy"):
						r.get_collider().enemy_health -= damage
						print("RevolverHit")
			anim_player.play("Revolver Fire")
			magazine_ammo -= 1
			ammo_capacity -= 1
			
func _reload_shotgun():
	if Input.is_action_just_pressed("Reload") and spare_ammo_sg >= 2:
		if not anim_player.is_playing():
			#anim_player.play("Shotgun reload")
			magazine_ammo = 2
			
func _reload_rifle():
	if Input.is_action_just_pressed("Reload") and spare_ammo_rifle >= 30:
		if not anim_player.is_playing():
			#anim_player.play("Rifle reload")
			magazine_ammo = 30
			
func _reload_revolver():
	if Input.is_action_just_pressed("Reload") and spare_ammo_revolver >= 6:
		if not anim_player.is_playing():
			#anim_player.play("Revolver reload")
			magazine_ammo = 6

func _inventory():
	var changed = false 
	if Input.is_action_just_pressed("Shotgun_Select"):
		weapon = weapon_state.SHOTGUN
		changed = true
	if Input.is_action_just_pressed("Melee_Select"):
		weapon = weapon_state.MELEE
		changed = true
	if Input.is_action_just_pressed("Pistol_Select"):
		weapon = weapon_state.REVOLVER
		changed = true
	if Input.is_action_just_pressed("Rifle_Select"):
		weapon = weapon_state.RIFLE
		changed = true
	if Input.is_action_just_pressed("Explosive_Select"):
		weapon = weapon_state.EXPLOSIVE
		changed = true
	if Input.is_action_just_pressed("Long_Range_Select"):
		weapon = weapon_state.LONG_RANGE
		changed = true
	if changed:
		update_weapon()
#Displays the animation and sets up the rays for the selected weapon to fire.
func _fire():
	match(weapon):
		weapon_state.SHOTGUN:
			_fire_shotgun()
		weapon_state.RIFLE:
			_fire_rifle()
		weapon_state.REVOLVER:
			_fire_revolver()
#Displays the animation and Reloads weapon.
func _reload():
	match(weapon):
		weapon_state.SHOTGUN:
			_reload_shotgun()
		weapon_state.RIFLE:
			_reload_rifle()
		weapon_state.REVOLVER:
			_reload_revolver()

#Individual frame basis for weapon firing and inventory.
func _process(_delta):
	_reload()
	_fire()
	_inventory()
#This is for functioned called every frame/ and movement code.
func _physics_process(delta):
	_wallrun()
	direction = Vector3()
	full_contact = ground_check.is_colliding()
	if is_on_floor() or _wallrun():
		air_acceleration = 1
		double_jump = 1

	if not is_on_floor() and not _wallrun():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration

	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		double_jump = 1
		air_acceleration = 1

	else:
		gravity_vec = -get_floor_normal()

	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump

	elif Input.is_action_just_pressed("jump") and double_jump == 1 and (is_on_floor() == false or ground_check.is_colliding() == false): 
		gravity_vec = Vector3.UP * jump
		double_jump = 0
		air_acceleration = 30

#Basic Movement Code
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("Dash"):
		player_state = state.DASHING
	elif Input.is_action_pressed("Sprint"):
		player_state = state.SPRINTING
	elif Input.is_action_pressed("Sliding"):# and !Input.is_action_pressed("Sprint"):
		pcap.shape.height -= transition_speed
		player_state = state.CROUCHING
	else:
		player_state = state.STANDING
		pcap.shape.height += transition_speed * delta
# This is for making the sliding code work.
	pcap.shape.height = clamp(pcap.shape.height, crouching_height, default_height)
	if Input.is_action_pressed("Sliding") and Input.is_action_pressed("Sprint"):
		pcap.shape.height -= transition_speed
		player_state = state.SLIDING
#	else:
#		player_state = state.STANDING
#		pcap.shape.height += transition_speed * delta * 2
	pcap.shape.height = clamp(pcap.shape.height, sliding_height, default_height)
	#This Controls the player states and matches them up.
	match(player_state):
		
		state.DASHING:
			print("dashing")
			h_acceleration = 200
			air_acceleration = 200
			dashtimer.start()

		state.SPRINTING:

			#print("sprinting")
			speed = sprinting_speed

		state.SLIDING:
			#print("sliding")
			speed = sliding_speed

		state.CROUCHING:

			#print("crouching")
			speed = crouch_speed

		state.STANDING:

			#print("standing")
			speed = standing_speed

	if not is_on_floor():
		print("Falling")

	direction = direction.normalized()
	
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	
	movement.z = h_velocity.z + gravity_vec.z
	
	movement.x = h_velocity.x + gravity_vec.x
	
	movement.y = gravity_vec.y
	
	movement = move_and_slide(movement, Vector3.UP)

func _on_Timer_timeout():
	air_acceleration = 1
	pass # Replace with function body.


func _on_GunTimer_timeout():
	print("BULLETFIRED")
	pass # Replace with function body.

func _on_StateTimer_timeout():
	pass # Replace with function body.


func _on_DashTimer_timeout():
	player_state = state.STANDING
	pass # Replace with function body.


func _on_Area_body_entered(body):
	if body.name == "KinematicBody":
		print("u die lol")
		get_tree().quit()
