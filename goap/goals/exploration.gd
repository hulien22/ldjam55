extends GoapGoal

class_name ExplorationGoal

func get_clazz() -> String: return "ExplorationGoal"

# always available
func is_valid() -> bool:
	return true

# lower priority compared to other goals
func priority() -> int:
	return 0

func get_desired_state() -> Dictionary:
	return {
		"exploring": true
	}
