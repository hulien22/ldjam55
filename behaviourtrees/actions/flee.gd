@tool
class_name FleeingAction extends ActionLeaf

func tick(actor, blackboard):
	# check if already fleeing and moving
	if (blackboard.get_value("is_fleeing", false) && blackboard.get_value("is_moving", false)):
		return RUNNING

	var enemies: Array = blackboard.get_value("enemies_in_range", [])
	if enemies.size() == 0:
		return FAILURE
	var avg_point:Vector2 = Vector2.ZERO
	for e in enemies:
		avg_point += e.global_position

	#var storm_rad: float = blackboard.get_value("storm_radius", 0.0)
	#if storm_rad > 0:
		#avg_point += actor.global_position.normalized() * storm_rad
		#avg_point = avg_point / (enemies.size() + 1)
	#else:
		#avg_point = avg_point / enemies.size()
	avg_point = avg_point / enemies.size()
		
	#TODO also handle stuffs with storm and center of screen
	#avg_point = avg_point / enemies.size()
	# 0.5 is to prefer going to center a bit more? not sure if this works
	#avg_point = avg_point / (enemies.size() + 0.5)
	
	var new_posn = actor.global_position - (avg_point - actor.global_position).normalized() * 100
	actor.move_towards(new_posn, true) #is_fleeing
		
	return RUNNING
