extends Position3D

export var rotate_speed = 1.0
export var move_speed = 1.0
export var move_speed_lr = 0.5
export var move_speed_fb = 1.5

var active_camera = 0
onready var cameras = [
	$"pivot/camera_drone",
	$"pivot/camera_spyglass",
	$"boat/camera_onboard"
]
const DEADZONE = 0.15

var angle_x = 0
var angle_y = 250

var _angle_x = 0
var _angle_y = 250

var move_to
var w = 0
var axis_value

var axis_value = Vector2()

func _ready():
	move_to = transform.origin

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0
		_angle_y += (angle_y - _angle_y) * delta * 10.0

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis

	if move_to != transform.origin:
		move_to.y = get_parent().get_height(transform.origin)
		transform.origin += (move_to - transform.origin) * delta * 10.0

func _input(event):
	if Input.is_action_pressed("game_left"):
		angle_y += rotate_speed
	if Input.is_action_pressed("game_right"):
		angle_y -= rotate_speed
	if Input.is_action_pressed("game_up"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to -= front_back * move_speed
	if Input.is_action_pressed("game_down"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to += front_back * move_speed
	if Input.is_key_pressed(KEY_ESCAPE):
		quit_game()
	if Input.is_action_pressed("game_a"):
		select_a()
	if Input.is_action_pressed("game_b"):
		select_b()

func _physics_process(delta):
	axis_value.x = Input.get_joy_axis(0, JOY_ANALOG_LX)
	axis_value.y = Input.get_joy_axis(0, JOY_ANALOG_LY)
		axis_value = Input.get_joy_axis(0, axis)
		var axis_abs = abs(axis_value)
		if axis_abs > DEADZONE:
			# ROTATE LEFT - RIGHT
			if axis == JOY_ANALOG_LX:
				angle_y -= rotate_speed * axis_value

			# ROTATE ..THE OTEHR WAY :P
			##
			#if axis == JOY_ANALOG_RY:
			#	if axis_value > 0:
			#		if angle_x > -25:
			#			angle_x -= rotate_speed * axis_abs
			#	else:
			#		if angle_x < 25:
			#			angle_x += rotate_speed * axis_abs

			# MOVE LEFT - RIGHT
			#if axis == JOY_ANALOG_LX:
			#	if axis_value < 0:
			#		var left_right = transform.basis.x
			#		left_right.y = 0.0
			#		left_right = left_right.normalized()
			#		move_to -= left_right * move_speed_lr * axis_abs;
			#	else:
			#		var left_right = transform.basis.x
			#		left_right.y = 0.0
			#		left_right = left_right.normalized()
			#		move_to += left_right * move_speed_lr * axis_abs;

			# MOVE FRONT - BACK
			if axis == JOY_ANALOG_LY:
				var front_back = transform.basis.z
				front_back.y = 0.0
				front_back = front_back.normalized()
				move_to += front_back * move_speed_fb * axis_value;



func select_a():
	get_parent().change_map_seed()

func select_b():
	cameras[active_camera].hide()
	active_camera += 1
	if active_camera > 2:
		active_camera = 0
	cameras[active_camera].show()
	cameras[active_camera].set_current(true)

func quit_game():
	get_tree().quit()