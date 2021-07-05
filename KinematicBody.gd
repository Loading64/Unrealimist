extends KinematicBody
const MAX_CAM_SHAKE = 0.3
var wall_normal
var player_health = 80
var ammo
var Assualt_rifle_magazine_ammo = 30
var Assualt_rifle_ammo_capacity = 150
var damage = 10
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
onready var dashtimer = $DashTimer
onready var statetimer = $StateTimer
onready var timer = $Timer
onready var pcap = $CollisionShape
onready var head = $Head
onready var wall_check = $wallcheck
onready var ground_check = $GroundCheck
onready var hand = $Head/Hand
onready var handloc = $Head/HandLoc
onready var anim_player = $AnimationPlayer
onready var camera = $Head/Camera 
onready var GunTimer = $Head/HandLoc/MeshInstance/RayCast/GunTimer
onready var gunraycast = $Head/HandLoc/MeshInstance/RayCast
enum weapon_state {MELEE,PISTOL,SHOTGUN,RIFLE,EXPLOSIVE,LONG_RANGE}
enum state  {SPRINTING, CROUCHING, STANDING, SLIDING, SHOOTING, DASHING}
var weapon = weapon_state.RIFLE
var player_state = state.STANDING
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
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


func _inventory():
	if Input.is_action_just_pressed("Shotgun_Select"):
		weapon = weapon_state.SHOTGUN
	if Input.is_action_just_pressed("Melee_Select"):
		weapon = weapon_state.MELEE
	if Input.is_action_just_pressed("Pistol_Select"):
		weapon = weapon_state.PISTOL
	if Input.is_action_just_pressed("Rifle_Select"):
		weapon = weapon_state.RIFLE
	if Input.is_action_just_pressed("Explosive_Select"):
		weapon = weapon_state.EXPLOSIVE
	if Input.is_action_just_pressed("Long_Range_Select"):
		weapon = weapon_state.LONG_RANGE
		
func _fire():
	if Input.is_action_pressed("Primary_fire"):
		if not anim_player.is_playing():
			camera.translation = lerp(camera.translation, 
					Vector3(rand_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE), 
					rand_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE), 0), 0.05)
			print("firing")
			if gunraycast.is_colliding():
				var target = gunraycast.get_collider()
				if target.is_in_group("Enemy"):
					print("hit enemy")
					target.enemy_health -= damage
		anim_player.play("AssualtFire")
	else:
		camera.translation = Vector3()
		anim_player.stop()
func _process(delta):
	_fire()
	_inventory()
	match(weapon):
		
		weapon_state.MELEE:
			print("Melee equipped")
			damage = 100
		weapon_state.PISTOL:
			print("Pistol equipped")
			damage = 35
		weapon_state.SHOTGUN:
			print("Shotgun equipped")
			damage = 20
		weapon_state.RIFLE:
			print("Rifle equipped")
			damage = 20
		weapon_state.EXPLOSIVE:
			print("Explosive equipped")
			damage = 70
		weapon_state.LONG_RANGE:
			print("Long Range equipped")
			damage = 200

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
		timer.start()

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

	pcap.shape.height = clamp(pcap.shape.height, crouching_height, default_height)
	
	if Input.is_action_pressed("Sliding") and Input.is_action_pressed("Sprint"):
		pcap.shape.height -= transition_speed
		player_state = state.SLIDING
#	else:
#		player_state = state.STANDING
#		pcap.shape.height += transition_speed * delta * 2
	pcap.shape.height = clamp(pcap.shape.height, sliding_height, default_height)
	
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
