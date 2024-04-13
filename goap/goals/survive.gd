extends GoapGoal

class_name SurviveGoal

func get_clazz() -> String: return "SurviveGoal"

func is_valid(_actor) -> bool:
	return true

func priority(actor) -> int:
	if (actor is NPC):
		var mh:float = actor.get_blackboard().get("max_health", 0);
		var ch:float = actor.get_blackboard().get("cur_health", 0);
		if (mh <= 0 || ch <= 0):
			return 0
		
		# TODO different formula
		return (1.0 - ch / mh) * 10
	return 0

func get_desired_state() -> Dictionary:
	return {
		"survive": true
	}
