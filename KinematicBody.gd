extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var standing_speed = 10
var speed = 10
var crouch_speed = 0
var transition_speed = 20
var sliding_speed = 40
var sprinting_speed = 40
var h_acceleration = 8
var air_acceleration = 1
var normal_acceleration = 6
var default_height = 1
var crouching_height = 0.1
var sliding_height = 0.5
var gravity = 10
var jump = 9
var full_contact = false
var double_jump = 1
var mouse_sensitivity = 0.06
var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var sliding = false
var crouching = false
onready var timer = $Timer
onready var pcap = $CollisionShape
onready var head = $Head
onready var ground_check = $GroundCheck
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

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
func _physics_process(delta):
	
	direction = Vector3()
	full_contact = ground_check.is_colliding()
	if is_on_floor():
		air_acceleration = 1
		double_jump = 1
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
		double_jump = 1
		air_acceleration = 1
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
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

	if Input.is_action_pressed("Sprint") and is_on_floor():
		speed = sprinting_speed 
		h_acceleration = sprinting_speed 
	elif not Input.is_action_pressed("Sliding") or Input.is_action_pressed("Sprint"):
		h_acceleration = 8
		speed = standing_speed

	if Input.is_action_pressed("Sliding") and not Input.is_action_just_pressed("Sprint"):
		pcap.shape.height -= transition_speed
		speed = crouch_speed
	else:
		speed = standing_speed
		pcap.shape.height += transition_speed * delta
	pcap.shape.height = clamp(pcap.shape.height, crouching_height, default_height)
	
	if Input.is_action_pressed("Sliding") and Input.is_action_pressed("Sprint"):
		pcap.shape.height -= transition_speed
		speed = sliding_speed
	else:
		speed = standing_speed
		pcap.shape.height += transition_speed * delta * 2
	pcap.shape.height = clamp(pcap.shape.height, sliding_height, default_height)

	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	movement = move_and_slide(movement, Vector3.UP)



func _on_Timer_timeout():
	air_acceleration = 1
	pass # Replace with function body.
