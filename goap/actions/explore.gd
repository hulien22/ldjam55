extends GoapAction
class_name ExploreAction

# Requires actor to have explore and done_movement functions.

func get_clazz() -> String: return "ExploreAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return true

func get_cost(_blackboard: Dictionary) -> int:
	return 1

func get_preconditions() -> Dictionary:
	return {}

func get_effects() -> Dictionary:
	return {
		"exploring": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	if (first_time):
		# TODO better exploration?
		actor.explore()
		return false
		
	return actor.done_movement()
