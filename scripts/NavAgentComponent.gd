class_name NavAgentComponent
extends NavigationAgent2D

@export var actor: Node2D

var first: bool = true
var can_move:bool = true

func _physics_process(delta):
		#target_position = new_target_posn
	if first:
		first = false # bug if called on first frame.
		return
	if !is_navigation_finished() && can_move:
		var next_posn:Vector2 = get_next_path_position()
		var dir = actor.global_position.direction_to(next_posn)
		actor.update_sprites(next_posn)
		actor.transform = actor.transform.translated(dir * actor.get_speed_mod() * delta)
	
	#else:
		#target_position = Vector2(randi()%size-size/2, randi()%size-size/2)
		#print(target_position)

func update_target_position(posn: Vector2):
	can_move = true
	set_target_position(posn)
	#print(target_position)

func cancel_movement():
	can_move = false

func done_movement() -> bool:
	return is_navigation_finished()

func is_moving() -> bool:
	return can_move && !done_movement()
