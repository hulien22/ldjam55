extends GoapAction
class_name DodgeAction

# Requires actor to have explore and done_movement functions.

func get_clazz() -> String: return "DodgeAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("closest_enemy") != null && !_blackboard.get("can_attack", false)

func get_cost(_blackboard: Dictionary) -> int:
	return 1

func get_preconditions() -> Dictionary:
	return {
		"in_range_of_enemy": true
	}

func get_effects() -> Dictionary:
	return {
		"staying_in_combat": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	if (first_time):
	# TODO replace -- strafe around?
		actor.explore()
		return false
		
	return actor.done_movement()

