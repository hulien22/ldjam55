extends Node2D
class_name NPC

@onready var nav_agent_component = $NavAgentComponent
#TODO remove
@export var size: int = 500

# Needs to be > NavAgent's Target desired distance ^ 2
@export var attack_range_sq: int = 26

var _action_planner: GoapActionPlanner = GoapActionPlanner.new()
var enemies_in_range: Array[NPC] = []
var _blackboard: Dictionary = {}
var _can_attack: bool = true
var _can_dash: bool = true

# TODO move elsewhere (component)
var _max_health: int = 10
var _health: int = 10
var _cooldown: float = 0.5

func _ready():
	var agent = GoapAgent.new()
	agent.init(self, [
		ExplorationGoal.new(),
		FightEnemiesGoal.new(),
		StayInCombatGoal.new()
	])
	
	add_child(agent)
	
	_action_planner.set_actions([
		ExploreAction.new(),
		AttackEnemyAction.new(),
		DodgeAction.new(),
		MoveTowardsEnemyAction.new()
	])
	
	_max_health = randi() % 7 + 3
	_health = _max_health
	_cooldown = randf() * 0.5 + 0.5

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return _blackboard

# Calculate at the start of finding a goal
func calculate_state():
	_blackboard = {
		"global_posn": global_position,
		"enemies_in_range" : enemies_in_range,
		"closest_enemy": get_nearest_enemy(),
		"attack_range_sq": attack_range_sq,
		"can_attack": _can_attack,
		"can_dash": _can_dash
	}

func skip_planning() -> bool:
	
	return false

func _on_scan_region_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox):
		return
	if (area != null && area.get_parent() is NPC):
		enemies_in_range.push_back(area.get_parent())

func _on_scan_region_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox):
		return
	if (area != null && area.get_parent() is NPC):
		enemies_in_range.erase(area.get_parent())

func get_nearest_enemy() -> NPC:
	var closest:NPC
	var closest_dist: float = 0
	for e in enemies_in_range:
		var dist: float = global_position.distance_squared_to(e.global_position)
		if (closest == null || dist < closest_dist):
			closest = e
			closest_dist = dist
	return closest

func attack_enemy(enemy):
	modulate = Color.RED
	print(self, " -> ", enemy)
	enemy.damage(1)
	_can_attack = false
	get_tree().create_timer(_cooldown).timeout.connect(func():
		_can_attack = true
	)
	
func damage(dmg: int):
	_health -= dmg
	$ProgressBar.value = _health * 100.0 / float(_max_health)
	if (_health <= 0):
		queue_free()

func explore():
	move_towards(Vector2(randi()%size-size/2, randi()%size-size/2))
	modulate = Color.BLUE

func move_towards(posn:Vector2):
	nav_agent_component.update_target_position(posn)
	modulate = Color.GREEN

func cancel_movement():
	move_towards(global_position)

func done_movement() -> bool:
	return nav_agent_component.is_navigation_finished()

