extends GoapAction

class_name CalmDownAction


func get_clazz() -> String: return "CalmDownAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {
		"protected": true
	}


func get_effects() -> Dictionary:
	return {
		"is_frightened": false
	}


func perform(actor, _delta: float, first_time: bool) -> bool:
	return actor.calm_down()
