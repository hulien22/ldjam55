@tool
class_name Fleeing2Action extends ActionLeaf

func tick(actor, blackboard):
	# check if already fleeing and moving
	if (blackboard.get_value("is_fleeing", false) && blackboard.get_value("is_moving", false)):
		return RUNNING

	var enemy: Vector2 = blackboard.get_value("closest_enemy_posn", Vector2.ZERO)
	if enemy == Vector2.ZERO:
		return FAILURE
	var avg_point:Vector2 = enemy

	var storm_rad: float = blackboard.get_value("storm_radius", 0.0)
	if storm_rad > 0:
		avg_point += actor.global_position.normalized() * storm_rad
		avg_point = avg_point / 1
		
	#TODO also handle stuffs with storm and center of screen
	#avg_point = avg_point / enemies.size()
	# 0.5 is to prefer going to center a bit more? not sure if this works
	#avg_point = avg_point / (enemies.size() + 0.5)
	
	var new_posn = actor.global_position - (avg_point - actor.global_position).normalized() * 100
	actor.move_towards(new_posn, true) #is_fleeing
		
	return RUNNING
