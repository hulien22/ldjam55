extends GoapAction
class_name FleeAction

# Moves around the enemy, if moving out of range then aborts

func get_clazz() -> String: return "FleeAction"

func is_valid(_blackboard: Dictionary) -> bool:
	# TODO also check if close to storm
	return _blackboard.get("closest_enemy") != null

func get_cost(_blackboard: Dictionary) -> int:
	return 2

func get_preconditions() -> Dictionary:
	return {}

func get_effects() -> Dictionary:
	return {
		"survive": true
	}

func perform(actor, _delta: float, first_time: bool) -> bool:
	if (first_time):
		var blackboard:Dictionary = actor.get_blackboard()
		#get all the enemies around
		var enemies: Array = blackboard.get("enemies_in_range", [])
		if enemies.size() == 0:
			return true
		var avg_point:Vector2 = Vector2.ZERO
		for e in enemies:
			avg_point += e.global_position
		avg_point = avg_point / enemies.size()
		
		var new_posn = actor.global_position - (avg_point - actor.global_position).normalized() * 100
		actor.move_towards(new_posn)
		return false
	
	return actor.done_movement()

