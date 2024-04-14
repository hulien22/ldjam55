extends GoapAction
class_name MoveTowardsEnemyAction

# Requires actor to have explore and done_movement functions.

func get_clazz() -> String: return "MoveTowardsEnemyAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("closest_enemy") != null

func get_cost(_blackboard: Dictionary) -> int:
	return 1

func get_preconditions() -> Dictionary:
	return {}

func get_effects() -> Dictionary:
	return {
		"in_range_of_enemy": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	var blackboard:Dictionary = actor.get_blackboard()
	var enemy: Node2D = blackboard.get("closest_enemy")
	if (enemy):
		if (enemy.global_position.distance_squared_to(actor.global_position) < blackboard.get("attack_range_sq", 0)):
			actor.cancel_movement()
			return true
		actor.move_towards(enemy.global_position)

	return actor.done_movement()
	#return false
