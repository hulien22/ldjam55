extends Node2D

@onready var agent = $NavigationAgent2D

#var agent: NavigationAgent2D
var first: bool = true
@export var size: int = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	agent = $NavigationAgent2D
	agent.target_position = Vector2(randi()%size-size/2, randi()%size-size/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if first:
		first = false
		return
	if not agent.is_target_reached() and not agent.is_navigation_finished():
		var dir = global_position.direction_to(agent.get_next_path_position())
		transform = transform.translated(dir)
	else:
		agent.target_position = Vector2(randi()%size-size/2, randi()%size-size/2)
		print(agent.target_position)
