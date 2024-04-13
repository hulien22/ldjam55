class_name NavAgentComponent
extends NavigationAgent2D

@export var actor: Node2D
@export var size: int = 500
@export var speed: float = 100

var first: bool = true

func _ready():
	target_position = Vector2(randi()%size-size/2, randi()%size-size/2)
	speed = randf() * 200 + 50

func _physics_process(delta):
	if first:
		first = false # bug if called on first frame.
		return
	if not is_target_reached() and not is_navigation_finished():
		var dir = actor.global_position.direction_to(get_next_path_position())
		actor.transform = actor.transform.translated(dir * speed * delta)
	else:
		target_position = Vector2(randi()%size-size/2, randi()%size-size/2)
		#print(target_position)
