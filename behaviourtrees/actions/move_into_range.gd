@tool
class_name MoveIntoRangeAction extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | move into range")
	var enemy: Node2D = blackboard.get_value("closest_enemy")
	if (enemy == null):
		return FAILURE
		#if (enemy.global_position.distance_squared_to(actor.global_position) < blackboard.get_value("attack_range_sq", 0)):
			#actor.cancel_movement()
			#return SUCCESS
	actor.move_towards(enemy.global_position)
	return RUNNING
