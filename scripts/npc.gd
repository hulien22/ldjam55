extends Node2D
class_name NPC

@onready var nav_agent_component = $NavAgentComponent
#TODO remove
@export var size: int = 500

# Needs to be > NavAgent's Target desired distance ^ 2
@export var attack_range_sq: int = 36

var _action_planner: GoapActionPlanner = GoapActionPlanner.new()
var enemies_in_range: Array[NPC] = []
var _blackboard: Dictionary = {}
var _can_attack: bool = true
var _can_dash: bool = true

# TODO move elsewhere (component)
var _health: float = 10
var _cooldown: float = 0.5

var base_stats: npc_base_stats
var my_line

signal died

func _ready():
	my_line = Line2D.new()
	my_line.default_color = Color.RED
	add_child(my_line)
	var agent = GoapAgent.new()
	agent.init(self, [
		ExplorationGoal.new(),
		FightEnemiesGoal.new(),
		SurviveGoal.new()
	])

	add_child(agent)

	_action_planner.set_actions([
		ExploreAction.new(),
		AttackEnemyAction.new(),
		StrafeAction.new(),
		MoveTowardsEnemyAction.new(),
		FleeAction.new(),
		RestAction.new()
	])

	_health = base_stats.max_health
	_cooldown = randf() * 0.5 + 0.5

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return _blackboard

# Calculate at the start of finding a goal
func calculate_state():
	var closest_enemy: NPC = get_nearest_enemy()
	var visible_enemies = get_visible_enemies()
	#var closest_enemy_dist:float = closest_enemy.global_position.distance_squared_to(global_position)

	_blackboard = {
		"global_posn": global_position,
		"enemies_in_range": enemies_in_range,
		"closest_enemy": closest_enemy,
		"visible_enemies" : visible_enemies,
		#"distance_sq_to_closest_enemy": closest_enemy_dist,
		#"in_range_of_enemy": (closest_enemy_dist <= attack_range_sq),
		"attack_range_sq": attack_range_sq,
		"can_attack": _can_attack,
		"can_dash": _can_dash,
		"max_health": base_stats.max_health,
		"cur_health": _health
	}
	if _can_attack:
		modulate = Color.GREEN
	else:
		modulate = Color.RED

func skip_planning() -> bool:
	return false

func _on_scan_region_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox):
		return
	if (area != null&&area.get_parent() is NPC):
		enemies_in_range.push_back(area.get_parent())

func _on_scan_region_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox):
		return
	if (area != null&&area.get_parent() is NPC):
		enemies_in_range.erase(area.get_parent())

func get_nearest_enemy() -> NPC:
	var closest: NPC = null
	var closest_dist: float = 0
	for e in enemies_in_range:
		var dist: float = global_position.distance_squared_to(e.global_position)
		if (closest == null||dist < closest_dist):
			closest = e
			closest_dist = dist
	return closest

func get_visible_enemies():
	var space_state = get_world_2d().direct_space_state
	var visible = []
	for enemy in enemies_in_range:
		var query = PhysicsRayQueryParameters2D.create(global_position, enemy.global_position)
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			visible.append(enemy)
		else:
			my_line.clear_points()
			my_line.add_point(Vector2.ZERO)
			my_line.add_point(enemy.global_position-global_position)
	if len(enemies_in_range) != len(visible):
		print("of " + str(len(enemies_in_range)) + " enemies " + str(len(visible)) + " are visible.")
	else:
		my_line.clear_points()
	return visible
		

func attack_enemy(enemy):
	modulate = Color.RED
	print(self, " -> ", enemy)
	enemy.damage(1, base_stats)
	_can_attack = false
	get_tree().create_timer(_cooldown).timeout.connect(func():
		_can_attack=true
	)

func damage(dmg: float, attacker: npc_base_stats):
	_health -= dmg
	$ProgressBar.value = _health * 100.0 / float(base_stats.max_health)
	if (_health <= 0):
		died.emit(attacker, base_stats)
		print(base_stats.first_name + " " + base_stats.last_name + " has died :(")
		queue_free()

func rest():
	damage(-0.01, base_stats)

func explore():
	move_towards(Vector2(randi() %size - size / 2, randi() %size - size / 2))
	#modulate = Color.BLUE

func move_towards(posn: Vector2):
	nav_agent_component.update_target_position(posn)
	#modulate = Color.GREEN

func cancel_movement():
	move_towards(global_position)

func done_movement() -> bool:
	return nav_agent_component.done_movement()
