extends Area2D

var camera_speed_wasd = 500 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var screen
var camera_speed_mouse = 500
var radius_required_to_move = 75


func _ready():
	screen = get_viewport_rect()
	screen_size = screen.size
	get_tree().get_root().size_changed.connect(_on_viewport_resize) 


func _process(delta):
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
		velocity = velocity.normalized() * camera_speed_wasd

	position += velocity * delta


	#Mouse on edge of screen control
	var mouse_position = get_viewport().get_mouse_position()

	if screen.has_point(mouse_position) && mouse_position.x < radius_required_to_move:
		position +=  Vector2.LEFT * camera_speed_mouse * delta

	if screen.has_point(mouse_position) && abs(mouse_position.x-screen_size.x) < radius_required_to_move:
		position +=  Vector2.RIGHT * camera_speed_mouse * delta

	if screen.has_point(mouse_position) && mouse_position.y < radius_required_to_move:
		position +=  Vector2.UP * camera_speed_mouse * delta

	if screen.has_point(mouse_position) && abs(mouse_position.y-screen_size.y) < radius_required_to_move && mouse_position.y < screen_size.y:
		position +=  Vector2.DOWN * camera_speed_mouse * delta

func _on_viewport_resize():
	print("resize")
	screen = get_viewport_rect()
	screen_size = screen.size
