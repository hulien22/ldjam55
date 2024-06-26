extends GoapAction
class_name StrafeAction

# Moves around the enemy, if moving out of range then aborts

func get_clazz() -> String: return "StrafeAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("closest_enemy") != null

func get_cost(_blackboard: Dictionary) -> int:
	return 10

func get_preconditions() -> Dictionary:
	return {
		"in_range_of_enemy": true
	}

func get_effects() -> Dictionary:
	return {
		"fighting_enemies": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	if (first_time):
	# TODO replace -- strafe around?
		actor.explore()
		return false
	
	var blackboard:Dictionary = actor.get_blackboard()
	var enemy: Node2D = blackboard.get("closest_enemy")
	if (enemy == null):
		return false
	
	return actor.done_movement() || enemy.global_position.distance_squared_to(actor.global_position) > blackboard.get("attack_range_sq", 0)

