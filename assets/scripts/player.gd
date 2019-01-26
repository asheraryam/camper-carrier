extends Position3D

export var rotate_speed = 1.0
export var move_speed = 1.0
export var move_speed_lr = 0.5
export var move_speed_fb = 1.5

var active_camera = 0
onready var cameras = [
	$"pivot/camera_drone",
	$"pivot/camera_spyglass",
	$"carrier/camera_onboard",
	$"carrier/camp/camera_camp"
]
onready var pivot_point = $"pivot"

const DEADZONE = 0.15

var angle_x = 0
var angle_y = 0

var _angle_x = 0
var _angle_y = 0

var move_to
var world
var w = 0

var axis_value = Vector2()
var cumulative = 0

func _ready():
	move_to = transform.origin
	world = get_parent()

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0
		_angle_y += (angle_y - _angle_y) * delta * 10.0

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis

	if move_to != transform.origin:
		var new_origin = transform.origin
		move_to.y = 0.0
		new_origin = transform.origin + (move_to - transform.origin) * delta * 10.0
		if world.get_height(new_origin, true) > world.SHALLOWS_LINE * world.MAP_HEIGHT_FACTOR:
			new_origin = transform.origin
			move_to = new_origin

		new_origin.y = transform.origin.y
		transform.origin = new_origin

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

	var current_axis = axis_value

	if active_camera != 2:
		current_axis = current_axis.rotated(deg2rad(-pivot_point.angle_y))

	if abs(current_axis.x) > DEADZONE:
		angle_y -= rotate_speed * current_axis.x
		pivot_point.angle_y += rotate_speed * current_axis.x

	if abs(current_axis.y) > DEADZONE:
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to += front_back * move_speed_fb * current_axis.y



func select_a():
	get_parent().change_map_seed()

func select_b():
	cameras[active_camera].hide()
	active_camera += 1
	if active_camera > cameras.size() -1:
		active_camera = 0
	cameras[active_camera].show()
	cameras[active_camera].set_current(true)

func quit_game():
	get_tree().quit()