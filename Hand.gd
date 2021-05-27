extends Spatial

var Hmouse_mov
var Hsway_threshold = 5
var Hsway_lerp = 5
var Vmouse_mov
var Vsway_threshold = 5
var Vsway_lerp = 5
export var sway_up : Vector3
export var sway_down : Vector3
export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		Vmouse_mov = -event.relative.y
		Hmouse_mov = -event.relative.x

func _process(delta):
	if Hmouse_mov != null:
		if Hmouse_mov > Hsway_threshold:
			rotation = rotation.linear_interpolate(sway_left, Hsway_lerp * delta)
		elif Hmouse_mov < -Hsway_threshold:
			rotation = rotation.linear_interpolate(sway_right, Hsway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, Hsway_lerp * delta)
	if Vmouse_mov != null:
		if Vmouse_mov > Vsway_threshold:
			rotation = rotation.linear_interpolate(sway_up, Vsway_lerp * delta)
		elif Vmouse_mov < -Vsway_threshold:
			rotation = rotation.linear_interpolate(sway_down, Vsway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, Vsway_lerp * delta)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
