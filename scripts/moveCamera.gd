class_name MoveCamera
extends Camera2D

var camera_speed_wasd = 500 # How fast the player will move (pixels/sec).
var screen_size:Vector2 # Size of the game window.
var screen
var camera_speed_mouse = 500
var radius_required_to_move = 75
var follow_player = true
var target

#var camera: Camera2D

@export var hold_zoom_speed: Vector2 = Vector2(3, 3)
@export var scroll_zoom_speed: Vector2 = Vector2(0.5, 0.5)
@export var zoom_min: Vector2 = Vector2(0.4, 0.4)
@export var zoom_max: Vector2 = Vector2(3.0, 3.0)

@export var ignore_mouse_regions: Array[BlockCameraMouseRect]


func _ready():
	#camera = $Camera2D
	screen = get_viewport_rect()
	screen_size = screen.size
	get_tree().get_root().size_changed.connect(_on_viewport_resize) 


func _process(delta):
	#print("camera", get_zoom())
	if Input.is_action_pressed("zoom_in") and get_zoom() < zoom_max:
		set_zoom(get_zoom() * (Vector2.ONE + hold_zoom_speed * delta))
	elif Input.is_action_pressed("zoom_out") and get_zoom() > zoom_min:
		set_zoom(get_zoom() / (Vector2.ONE + hold_zoom_speed * delta))
	elif Input.is_action_just_released("wheel_in") and get_zoom() < zoom_max:
		set_zoom(get_zoom() * (Vector2.ONE + scroll_zoom_speed))
	elif Input.is_action_just_released("wheel_out") and get_zoom() > zoom_min:
		set_zoom(get_zoom() / (Vector2.ONE + scroll_zoom_speed))
		
	if Input.is_action_just_pressed("toggle_camera_follow"):
		follow_player = !follow_player
	if follow_player and target and is_instance_valid(target):
		global_position = target.global_position
		#clamp_to_limits()
		return
	#WASD control
	var velocity = Vector2.ZERO 
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * camera_speed_wasd / zoom.x

	position += velocity * delta


	#Mouse on edge of screen control
	if is_mouse_movement_enabled():
		var mouse_position = get_viewport().get_mouse_position()
		var mouseVelocity = Vector2.ZERO
		if screen.has_point(mouse_position) && mouse_position.x < radius_required_to_move:
			mouseVelocity +=  Vector2.LEFT 

		if screen.has_point(mouse_position) && abs(mouse_position.x-screen_size.x) < radius_required_to_move:
			mouseVelocity +=  Vector2.RIGHT 

		if screen.has_point(mouse_position) && mouse_position.y < radius_required_to_move:
			mouseVelocity +=  Vector2.UP 

		if screen.has_point(mouse_position) && abs(mouse_position.y-screen_size.y) < radius_required_to_move && mouse_position.y < screen_size.y:
			mouseVelocity +=  Vector2.DOWN 

		position += mouseVelocity.normalized() * camera_speed_mouse * delta / zoom.x
	clamp_to_limits()

func clamp_to_limits():
	# clamp position to screen
	var x = screen_size.x / 2 / zoom.x
	var y = screen_size.y / 2 / zoom.y
	position.x = clamp(position.x, limit_left+x, limit_right-x)
	position.y = clamp(position.y, limit_top+y, limit_bottom-y)

func _on_viewport_resize():
	screen = get_viewport_rect()
	screen_size = screen.size

func is_mouse_movement_enabled() -> bool:
	for r in ignore_mouse_regions:
		if r.is_mouse_inside():
			return false
	return true
