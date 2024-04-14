extends GoapAction
class_name RestAction

func get_clazz() -> String: return "RestAction"

func is_valid(_blackboard: Dictionary) -> bool:
	return true

#expensive, only should do this if no other options
func get_cost(_blackboard: Dictionary) -> int:
	return 5

func get_preconditions() -> Dictionary:
	return {}

func get_effects() -> Dictionary:
	return {
		"survive": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	actor.rest()
	return true;

