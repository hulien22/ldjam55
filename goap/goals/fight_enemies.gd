extends GoapGoal

class_name FightEnemiesGoal

func get_clazz() -> String: return "FightEnemiesGoal"

func is_valid(actor) -> bool:
	if (actor is NPC):
		# TODO also check health? also check has weapon?
		return actor.get_blackboard().get("enemies_in_range", []).size() > 0 #&& actor.get_blackboard().get("can_attack", false)
	return false

# lower priority compared to other goals
func priority(_actor) -> int:
	return 7

func get_desired_state() -> Dictionary:
	return {
		"fighting_enemies": true
	}
