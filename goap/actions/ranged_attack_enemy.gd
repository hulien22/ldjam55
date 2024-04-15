extends GoapAction
class_name RangedAttackEnemyAction

# Requires actor to have explore and done_movement functions.

func get_clazz() -> String: return "RangedAttackEnemyAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("closest_visible_enemy") != null && _blackboard.get("can_attack", false) && _blackboard.get("has_ranged_weapon", false)

func get_cost(_blackboard: Dictionary) -> int:
	return 0

func get_preconditions() -> Dictionary:
	return {
		"in_range_of_enemy": true,
		"has_visible_enemy": true
	}

func get_effects() -> Dictionary:
	return {
		"fighting_enemies": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	if (first_time):
		var blackboard:Dictionary = actor.get_blackboard()
		var enemy: Node2D = blackboard.get("closest_visible_enemy")
		if (enemy):
			actor.attack_enemy(enemy)
	
	return true
