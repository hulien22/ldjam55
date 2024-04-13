extends Node2D

@onready var nav_agent_component = $NavAgentComponent
@export var size: int = 500

var _action_planner: GoapActionPlanner = GoapActionPlanner.new()

func _ready():
	var agent = GoapAgent.new()
	agent.init(self, [
		ExplorationGoal.new()
	])
	
	add_child(agent)
	
	_action_planner.set_actions([
		ExploreAction.new()
	])

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return {}

func explore():
	nav_agent_component.update_target_position(Vector2(randi()%size-size/2, randi()%size-size/2))

func done_movement() -> bool:
	return nav_agent_component.is_navigation_finished()
